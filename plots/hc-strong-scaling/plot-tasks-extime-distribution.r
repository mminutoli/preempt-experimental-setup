packages = c('docopt', 'ggplot2', 'scales', 'latex2exp')

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
        to_iteration <- max(dt$Iteration, na.rm = TRUE)
    dt <- dt[which(dt$Iteration >= from_iteration & dt$Iteration <= to_iteration), ]
    dt$Iteration <- as.factor(dt$Iteration)
    dt$ExecutionTime <- dt$ExecutionTime * 10^3
    return(dt)
}

plotTaskDuration <- function(df, output_file) {
    ggplot(df, aes(Iteration, ExecutionTime, group=Iteration, color=WorkerID)) +
        scale_y_continuous(trans = log10_trans(),
                           breaks = trans_breaks("log10", function(x) 10^x),
                           labels = trans_format("log10", math_format(10^.x))) +
        geom_violin(trim=FALSE) +
        labs(x = 'Iteration (#)', y = TeX('Execution Time $(\\mu s)$')) +
        theme(legend.position = 'top', legend.direction='horizontal') +
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
