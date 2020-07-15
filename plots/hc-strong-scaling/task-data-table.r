packages = c('docopt', 'rjson')

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
-o FILE     Specify the name of the output file." -> doc

loadDataFrame <- function(inputs) {
    df <- fromJSON(file = inputs)[[1]]
    dt <- data.frame(Iteration=integer(), WorkerID=integer(), ExecutionTime=double())

    to_iteration = length(df$BuildCountersTasks)
    itrID = 1
    for (iteration in df$BuildCountersTasks) {
        if (itrID > to_iteration) break
        workerID <- as.integer(1);
        for (samples in iteration) {
            block <- data.frame(Iteration=itrID, WorkerID=workerID, ExecutionTime=samples)
            dt <- rbind(dt, block)
            workerID <- workerID + 1
        }
        itrID <- itrID + 1
    }

    return(dt)
}

main <- function() {
    args <- docopt(doc)
    data <- loadDataFrame(args$INPUT)
    write.csv(data, args$o)
}

main()
