packages = c('docopt', 'ggplot2', 'reshape2', 'jsonlite')

package.check <- lapply(
    packages,
    FUN = function(x) {
        if (!require(x, character.only = TRUE)) {
            install.packages(x, repos = "http://cran.us.r-project.org",
                             dependencies = TRUE)
            library(x, character.only = TRUE)
        }
    })


"Usage: plot.r [-ho FILE] [INPUT ...]

-h --help   Display this help message.
-o FILE     Specify the name of the output file." -> doc

reduceArray <- function(x) {
    Reduce(sum, x)
}

loadDataFrame <- function(inputs) {
    df = data.frame()
    for (filename in inputs) {
        row <- fromJSON(filename)
        df <- rbind(row, df)
    }
    df$Time <- df$Total / 1000
    df <- subset(df, select=c(WorldSize, Input, Time))
    return(df)
}

strongScalingPlot <- function(df, output_file) {
    cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
    ggplot(df, aes(WorldSize, Time, color=Input, shape=Input, linetype=Input)) +
        geom_line(size=1.5) +
        geom_point(size=4) +
        scale_x_continuous(trans = 'log2', breaks=c(2,4,8,16,32,64,128)) +
        scale_y_continuous(trans = 'log2') +
        labs(x = 'Summit Nodes (#)', y = 'Execution Time (s)') +
        scale_fill_manual(values=cbPalette) +
        scale_colour_brewer(palette = "Dark2") +
        theme_bw() +
        theme(legend.position = 'top', legend.direction = 'horizontal')
    ggsave(output_file, height=5, width=5)
}

main <- function() {
    args <- docopt(doc)
    data <- loadDataFrame(args$INPUT)
    strongScalingPlot(data, args$o)
}

main()
