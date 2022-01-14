# penguins-hpc

This is a shiny app that demonstrates a possible way to interface a shiny app with an HPC cluster. The app can be deployed on a shiny server or on RStudio Connect. The idea is to use the compute power of the HPC in order to keep the interactivity of the app reasonable despite the need for complex and large scale computations.

## Design Goals

Various options exist to connect a shiny app to the HPC exist. Any such option will trigger different implementations. Those options range from very tight to a very loose integration with various magnitude of changes on the shiny and HPC infrastructure.

## R packages used to interface with an HPC cluster

There is many R packages available for High Performance Computing (HPC) . The secion "Resource Managers and batch schedulers" on the [HPC task view on CRAN](https://cran.r-project.org/web/views/HighPerformanceComputing.html) is particularly helpful for the work presented here. We are picking two packages here: 
 
* [clustermq](https://mschubert.github.io/clustermq/) - remnotely run gneric R code on a HPC cluster using the [zeromq](https://zeromq.org/) framework.
* [batchtools](https://mllg.github.io/batchtools/) - Map Reduce in R

## Pro & Contra for both packages


|    | clustermq |     batchtools          |
|----------|:-------------|:------|
| Pro |  <ul><li>runs in memory - very fast and extremely scalable</li><li>generic scheduling of R functions as well as loops</li><li>can run any parXapply functions against the clustermq parallel backend</ul> |  <ul><li>No OS dependencies</li><li>use of transient disk space for job registry allows to selectively re-run failed tasks</li></ul> |
| Contra | <ul><li>depends on zeromq (OS package)</li><li>since everything runs in-memory, a failed/errored partial task is difficult to re-run </li></ul>| <ul><li>use of transient disk space for job registry creates significant overhead when it comes to scalability</li><li>slower than clustermq for short tasks</li><li>designed for Map Reduce calls</li></ul> |

For the following, we will focus on clustermq as a package of choice. 

## Connecting a shiny app with HPC via clustermq




