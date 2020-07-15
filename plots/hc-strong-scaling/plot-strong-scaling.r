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
    df$Reduction <-
        as.numeric(lapply(df$NetworkReductions, reduceArray)) / 1000
    df$Total <- df$Total / 1000
    df$Sampling <- df$Sampling / 1000
    df$SeedSelection <- df$SeedSelection / 1000
    df$SeedSelection <- df$SeedSelection - df$Reduction
    df <- subset(df, select=c(WorldSize, Sampling, SeedSelection, Reduction, Total))
    df <- melt(df, id=c('WorldSize'))
    colnames(df)[2] = 'Phase'
    colnames(df)[3] = 'Time'
    return(df)
}

strongScalingPlot <- function(df, output_file) {
    cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
    ggplot(df, aes(WorldSize, Time, fill=Phase)) +
        geom_bar(stat='identity', position = 'dodge') +
        scale_x_continuous(trans = 'log2',  limits=c(1.25, 196),
                           breaks=c(2,4,8,16,32,64,128)) +
        labs(x = 'Summit Nodes (#)', y = 'Execution Time (s)') +
        scale_fill_manual(values=cbPalette, name = "", labels = c("Sampling", "Counting", "SeedSelect", "Total")) +
        scale_colour_manual(values=cbPalette) +
        theme_bw() +
        theme(text = element_text(size=22), legend.position = 'top', legend.direction = 'horizontal')
    ggsave(output_file, height=7, width=7)
}

main <- function() {
    args <- docopt(doc)
    data <- loadDataFrame(args$INPUT)
    strongScalingPlot(data, args$o)
}

main()
