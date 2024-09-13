#!/usr/bin/env Rscript

# author Romain Guerillot <guerillot.romain@gmail.com>
# references Meier R, Kores P, & Darwin S. 1991. Homoplasy slope ratio: a 
#            better measurement of observed homoplasy in cladistic analyses. 
#            Sys. Zool. 40(1):74-88.
#            Kerrin Mendler et al. AnnoTree: visualization and exploration of 
#            a functionally annotated microbial tree of life. Nucleic Acids Research.
#            Volume 47, Issue 9, 21 May 2019, https://doi.org/10.1093/nar/gkz246


# Functions
get_mutated_strain <- function(mut_id, mut_data) {
  message(paste("Running mutation id: ", argv$mutation_id))
  temp <- system(command=paste("sgrep ", "\"", mut_id, "\" ", mut_data, sep=""), intern=T)
  sapply(strsplit(temp,"\t"), getElement, 2)
}

get_named_vector_of_mutation_state <- function(mutated_strain, tree){
  x <- setNames(rep(0, length(tree$tip.label)), tree$tip.label)
  x <- replace(x, mutated_strain, 1)
  return(x)
} 

measure_homoplasy <- function(tree, data, nsims=100, avg_hs_random) {
  #require(phangorn)

  num_taxa_t <- length(data)
  tip_levels <- as.character(unique(data))
  
  data.phyDat <- phangorn::as.phyDat(sapply(data, as.character), type = "USER", levels = tip_levels)

  # Mutation count
  mut_count <- sum(data == 1)
	
  # Consistency index
  ci_real <- phangorn::CI(tree, data.phyDat)
  
  # Extra steps (number of acquisition) 
  es_real <-  1/ci_real
  
  # Homoplasy slope of data
  hs_real <- es_real/(num_taxa_t - 3)
  
  # Average homoplasy slope of random data with same # taxa
  if (avg_hs_random == "NULL") {
    random_data <- replicate(nsims, 
                             setNames(sample(tip_levels, 
                                             num_taxa_t,
                                             replace = TRUE), 
                                      tree$tip.label), 
                             simplify = FALSE)
    random_data.phyDat <- lapply(random_data,
                                 phangorn::as.phyDat, type = "USER", levels = tip_levels)
    es_random <- unlist(lapply(random_data.phyDat, function(tip_states){
      1/phangorn::CI(tree, tip_states) - 1}))
    hs_random <- es_random/(num_taxa_t - 3)
    avg_hs_random <- mean(hs_random)
  }
  
  # Homoplasy slope ratio
  hsr <- hs_real/avg_hs_random 

  message(paste("Mutation count: ", mut_count))	
  message(paste("No convergent acquisition: ", es_real))
  message(paste("Homoplasy slope: ", hs_real))
  message(paste("Consistency index: ", ci_real))
  message(paste("Average homoplasy slope of random data with same no of strain: ", avg_hs_random))
  message(paste("Homoplasy slope ratio: ", hsr))
      
  cat(paste(mut_count, es_real, ci_real, hs_real, avg_hs_random, hsr, "\n", sep="\t"))

}


# Main functiom
#require(phangorn)
main <- function(tree_path, mut_data_path, mutation_id, nsims=100, avg_hs_random = NULL) {
  #require(ape)
  my_tree <- ape::read.tree(as.character(tree_path))
  mut_strain <- get_mutated_strain(mutation_id, mut_data_path)
  mut_strain <- get_named_vector_of_mutation_state(mut_strain, my_tree)
  
  if (avg_hs_random == "NULL"){
    return(measure_homoplasy(my_tree, mut_strain, nsims))
  }
  
  return(measure_homoplasy(my_tree, mut_strain, nsims, avg_hs_random))
}

# Read argument
require(argparser)
p <- arg_parser("R script to measure homoplastic scores of a mutation (ES, CI, HS, HSR)\n
				!!! mutation database need to be sorted with mutation id as 1st column (sgrep requirement)")

# Add a positional argument
p <- add_argument(p, "tree", help="tree in newick format")
p <- add_argument(p, "mutation_db", help="sorted mutation database (first column is mutation id)")
p <- add_argument(p, "mutation_id", help="mutation id")

# Add a optionnal argument
p <- add_argument(p, "--nsims", help="number of simulation to run to calculate average homoplasy slope", default=100)
p <- add_argument(p, "--avg_hs", help="use this average homoplasy slope ratio and skip simulation", default="NULL")

# Print the help message
#print(p)

# parse argument from command line
argv <- parse_args(p)

# Run
cat(argv$mutation_id, "\t")
main(argv$tree, argv$mutation_db, argv$mutation_id, nsims=as.numeric(argv$nsims), avg_hs_random=as.numeric(argv$avg_hs))
  

