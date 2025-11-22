#!/usr/bin/env Rscript

# author: Romain Guerillot <guerillot.romain@gmail.com>
# Homoplasy metrics after Meier et al. 1991.

suppressPackageStartupMessages({
  if (!requireNamespace("ape", quietly=TRUE)) stop("Package 'ape' required.")
  if (!requireNamespace("phangorn", quietly=TRUE)) stop("Package 'phangorn' required.")
  if (!requireNamespace("argparser", quietly=TRUE)) stop("Package 'argparser' required.")
})

get_mutated_strain <- function(mut_id, mut_data_path) {
  cmd <- sprintf("grep -P '^%s\\t' %s", mut_id, shQuote(mut_data_path))
  raw <- tryCatch(system(cmd, intern = TRUE), error = function(e) character(0))
  if (!length(raw)) {
    message(sprintf("Mutation id '%s' not found; returning empty set.", mut_id))
    return(character(0))
  }
  strains <- vapply(strsplit(raw, "\\t"), function(x) if (length(x) >= 2) x[2] else NA_character_, character(1))
  strains[!is.na(strains)]
}

get_named_vector_of_mutation_state <- function(mutated_strain, tree){
  x <- setNames(rep(0L, length(tree$tip.label)), tree$tip.label)
  if (length(mutated_strain)) {
    present <- intersect(mutated_strain, names(x))
    x[present] <- 1L
  }
  x
}

measure_homoplasy <- function(tree, data, nsims=0, avg_hs_override=NULL) {
  num_taxa <- length(data)
  levels_states <- c("0","1")
  data_char <- setNames(as.character(data), names(data))
  data.phyDat <- phangorn::as.phyDat(data_char, type="USER", levels=levels_states)

  mut_count <- sum(data == 1L)
  if (mut_count == 0) {
    message("No mutated taxa; returning default metrics (number of acquisitions = 0).")
    return(list(
      mutated_tip_count = 0L,
      number_of_acquisitions = 0L,
      consistency_index = NA_real_,
      homoplasy_slope = NA_real_,
      avg_random_hs = NA_real_,
      homoplasy_slope_ratio = NA_real_
    ))
  }

  ci_real <- phangorn::CI(tree, data.phyDat)
  es_real <- (1/ci_real) - 1
  num_acq <- es_real + 1
  num_acq_int <- as.integer(round(num_acq))
  hs_real <- es_real/(num_taxa - 3)

  avg_hs_random <- NA_real_
  if (!is.null(avg_hs_override)) {
    avg_hs_random <- avg_hs_override
  } else if (nsims > 0) {
    random_states_list <- replicate(nsims, {
      rnd <- sample(c(0L,1L), num_taxa, replace=TRUE)
      rnd_named <- setNames(as.character(rnd), names(data))
      phangorn::as.phyDat(rnd_named, type="USER", levels=levels_states)
    }, simplify=FALSE)
    es_random <- vapply(random_states_list, function(tip_states){
      (1/phangorn::CI(tree, tip_states)) - 1
    }, numeric(1))
    hs_random <- es_random/(num_taxa - 3)
    avg_hs_random <- mean(hs_random)
  }

  hsr <- if (!is.na(avg_hs_random) && avg_hs_random != 0) hs_real/avg_hs_random else NA_real_

  message(sprintf("Mutation count: %d", mut_count))
  message(sprintf("Number of acquisitions: %d", num_acq_int))
  message(sprintf("Consistency index: %.3f", ci_real))
  message(sprintf("Extra steps: %.3f", es_real))
  message(sprintf("Homoplasy slope: %.6f", hs_real))
  if (!is.na(avg_hs_random)) {
    message(sprintf("Average random Homoplasy slope: %.6f", avg_hs_random))
    message(sprintf("Homoplasy slope ratio: %.6f", hsr))
  } else {
    message("Average random Homoplasy slope: not computed (nsims=0 and no --avg_hs supplied).")
  }

  list(
    mutated_tip_count = mut_count,
    number_of_acquisitions = num_acq_int,
    consistency_index = ci_real,
    homoplasy_slope = hs_real,
    avg_random_hs = avg_hs_random,
    homoplasy_slope_ratio = hsr
  )
}

main <- function(tree_path, mut_data_path, mutation_id, nsims=0, avg_hs_override=NULL) {
  tree <- ape::read.tree(tree_path)
  mutated <- get_mutated_strain(mutation_id, mut_data_path)
  vec <- get_named_vector_of_mutation_state(mutated, tree)
  measure_homoplasy(tree, vec, nsims=nsims, avg_hs_override=avg_hs_override)
}

header_fields <- c("mutation_id",
                   "mutated_tip_count",
                   "number_of_acquisitions",
                   "consistency_index",
                   "homoplasy_slope",
                   "avg_random_hs",
                   "homoplasy_slope_ratio")

format_int <- function(x) {
  ifelse(is.na(x), "NA", as.character(as.integer(x)))
}

format_num <- function(x, digits=6) {
  ifelse(is.na(x), "NA", formatC(x, format="f", digits=digits))
}

p <- argparser::arg_parser("Compute homoplasy metrics (Number of acquisitions, Consistency Index, Homoplasy Slope, Homoplasy Slope Ratio) for a mutation id.")
p <- argparser::add_argument(p, "tree", help="tree in newick format")
p <- argparser::add_argument(p, "mutation_db", help="sorted mutation database (first column is mutation id)")
p <- argparser::add_argument(p, "mutation_id", help="mutation id")
p <- argparser::add_argument(p, "--nsims", help="number of simulation to run to calculate average homoplasy slope", default=0)
p <- argparser::add_argument(p, "--avg_hs", help="use this average homoplasy slope ratio and skip simulation", default="NULL")
p <- argparser::add_argument(p, "--print_header", help="print header row before the metrics", flag=TRUE)
argv <- argparser::parse_args(p)

avg_hs_value <- if (argv$avg_hs == "NULL") NULL else suppressWarnings(as.numeric(argv$avg_hs))
metrics <- main(argv$tree,
                argv$mutation_db,
                argv$mutation_id,
                nsims=as.numeric(argv$nsims),
                avg_hs_override=avg_hs_value)

if (argv$print_header) {
  cat(paste(header_fields, collapse="\t"), "\n")
}

row_values <- c(
  argv$mutation_id,
  format_int(metrics$mutated_tip_count),
  format_int(metrics$number_of_acquisitions),
  format_num(metrics$consistency_index),
  format_num(metrics$homoplasy_slope),
  format_num(metrics$avg_random_hs),
  format_num(metrics$homoplasy_slope_ratio)
)

cat(paste(row_values, collapse="\t"), "\n")