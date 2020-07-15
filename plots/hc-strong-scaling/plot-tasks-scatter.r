packages = c('docopt', 'readr', 'ggplot2')

package.check <- lapply(
    packages,
    FUN = function(x) {
        if (!require(x, character.only = TRUE)) {
            install.packages(x, repos = "http://cran.us.r-project.org",
                             dependencies = TRUE)
            library(x, character.only = TRUE)
        }
    })

"Usage: plot.r [-h] -o FILE [--from=<b> --to=<e>] INPUT

-h --help   Display this help message.
--from=<b>  Sart Iteration [default: 1].
--to=<e>    Last Iteration [default: 0].
-o FILE     Specify the name of the output file." -> doc

loadDataFrame <- function(inputs, from_iteration, to_iteration) {
    dt <- read.csv(inputs)
    if (to_iteration == 0)
        to_iteration <- max(dt$Iteration)
    dt <- dt[which(dt$Iteration >= from_iteration & dt$Iteration <= to_iteration), ]
    return(dt)
}

plotTaskDuration <- function(df, output_file) {
    ggplot(df, aes(WorkerID, ExecutionTime, color=Iteration)) +
        geom_point() +
        geom_vline(xintercept=78, colour="grey") +
        geom_text(aes(x=78, label="GPUs\n", y=max(df$ExecutionTime)/2), colour="#e41a1c", angle=0, text=element_text(size=11)) +
        geom_text(aes(x=78, label="\nCPUs", y=max(df$ExecutionTime)/2), colour="#4daf4a", angle=0, text=element_text(size=11)) +
        labs(x = 'Worker ID', y = 'Execution Time (ms)') +
        theme(legend.position = 'top', legend.direction = 'horizontal') +
        coord_flip() +
        theme_bw()

    ggsave(output_file, height=4, width=5)
}

main <- function() {
    args <- docopt(doc)
    data <- loadDataFrame(args$INPUT, as.numeric(args$from),
                          as.numeric(args$to))
    plotTaskDuration(data, args$o)
}

main()
