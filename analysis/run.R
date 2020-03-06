#!/usr/bin/Rscript

require(tidyverse)

#bdsg.prof <- read.delim('expanded_profiling.cleaned.tsv.gz')
bdsg.prof <- read.delim('fixed_handle_profiling.cleaned.tsv.gz')
summary(bdsg.prof)
wideScreen <- function(howWide=Sys.getenv("COLUMNS")) {
  options(width=as.integer(howWide))
}
wideScreen(140)
bdsg.prof$graph.model <- factor(bdsg.prof$sglib.model,levels(bdsg.prof$sglib.model)[c(4,1:3,5)])

sink("build.mem.lm.txt"); with(bdsg.prof, summary(lm(build.mem ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
#sink("build.mem.no_og.lm.txt"); with(subset(bdsg.prof, graph.model != "og"), summary(lm((build.mem) ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
#sink("build.mem.no_xg.lm.txt"); with(subset(bdsg.prof, graph.model != "xg"), summary(lm((build.mem) ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
#sink("build.mem.no_og_xg.lm.txt"); with(subset(bdsg.prof, graph.model != "xg" & graph.model != "og"), summary(lm((build.mem) ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
sink("load.mem.lm.txt"); with(bdsg.prof, summary(lm(load.mem ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
sink("handle.enumeration.time.lm.txt"); with(bdsg.prof, summary(lm(handle.enumeration.time/graph.node.count ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
sink("edge.traversal.time.lm.txt"); with(bdsg.prof, summary(lm(edge.traversal.time/graph.edge.count ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()
sink("path.traversal.time_subset_with_paths.lm.txt"); with(subset(bdsg.prof, graph.step.count > 0), summary(lm(path.traversal.time/graph.step.count ~ graph.model + graph.model * (graph.node.count + graph.edge.count + graph.path.count + graph.step.count + graph.avg.path.depth + graph.seq.length + graph.max.degree + graph.avg.degree + graph.cyclic + graph.avg.edge.delta + graph.feedback.fraction + graph.feedback.arc.count)))); sink()



#ggplot(bdsg.prof, aes(x=graph.seq.length, y=graph.node.count/handle.enumeration.time, color=graph.model)) + geom_point() + scale_x_log10()
#ggsave("bdsg.prof_steps.per.second_vs_seq.length.pdf", width=9.3, height=4.71)
ggplot(subset(bdsg.prof,graph.model=="vg"), aes(y=graph.avg.degree, x=graph.seq.length, color=graph.avg.path.depth, shape=graph.avg.path.depth==0)) + geom_point(alpha=I(1/3)) + scale_x_log10("graph sequence length (bp)", breaks = c(1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9)) + scale_y_continuous("average node degree") + theme_bw() + theme_bw() + scale_shape_discrete("has paths") + scale_color_gradientn("path depth", colors=c("blue", "red", "yellow"), breaks=c(0,10,20,30,40,50,60))
ggsave("graph_summary.png", height=4.41, width=5.99)
ggsave("graph_summary.pdf", height=4.41, width=5.99)
ggsave("bdsg.prof_avg.degree_vs_log10.seq.length_color_avg.path.depth.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_avg.degree_vs_log10.seq.length_color_avg.path.depth.png", width=9.3, height=4.71)

bdsg.prof$handles.per.sec <- bdsg.prof$graph.node.count / bdsg.prof$handle.enumeration.time
bdsg.prof$edges.per.sec <- bdsg.prof$graph.edge.count / bdsg.prof$edge.traversal.time
bdsg.prof$steps.per.sec <- bdsg.prof$graph.step.count / bdsg.prof$path.traversal.time

bdsg.prof.df.iter <- pivot_longer(bdsg.prof, cols=c(handles.per.sec, edges.per.sec, steps.per.sec))
bdsg.prof.df.iter$name <- as.factor(bdsg.prof.df.iter$name)
levels(bdsg.prof.df.iter$name) <- c("edges per second", "handles per second", "steps per second")
bdsg.prof.df.iter <- subset(bdsg.prof.df.iter, value>0) # remove a handful of failures

ggplot(subset(bdsg.prof.df.iter, value>0), aes(x=graph.seq.length, y=value, color=graph.model)) + geom_point(size=0.5, alpha=I(1/2)) + scale_x_log10("graph sequence length (bp)", breaks = c(1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9)) + scale_y_log10("", breaks = c(1e4,1e5,1e6,1e7,1e8,1e9,1e10,1e11)) + scale_color_discrete("model") + facet_grid(name ~ ., scales = "free_y") + theme_bw()
ggsave("iteration_per_second.pdf", height=8, width=6.7)
ggsave("iteration_per_second.png", height=8, width=6.7)

bdsg.prof.df.mem <- pivot_longer(bdsg.prof, cols=c(build.mem, load.mem))
bdsg.prof.df.mem$name <- as.factor(bdsg.prof.df.mem$name)
levels(bdsg.prof.df.mem$name) <- c("build memory (bytes)", "load memory (bytes)")
bdsg.prof.df.mem <- subset(bdsg.prof.df.mem, value>0) # remove a handful of failures

ggplot(subset(bdsg.prof.df.mem, value>0), aes(x=graph.seq.length, y=value*1000, color=graph.model)) + geom_point(size=0.5, alpha=I(1/2)) + scale_x_log10("graph sequence length (bp)", breaks = c(1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9)) + scale_y_log10("", breaks = c(1e4,1e5,1e6,1e7,1e8,1e9,1e10,1e11)) + scale_color_discrete("model") + facet_grid(name ~ ., scales = "free_y") + theme_bw()
ggsave("build_and_load_memory.pdf", height=7, width=6.7)
ggsave("build_and_load_memory.png", height=7, width=6.7)


ggplot(bdsg.prof, aes(x=graph.seq.length, y=handles.per.sec, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_handles.per.second_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_handles.per.second_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=graph.seq.length, y=edges.per.sec, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_edges.per.second_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_edges.per.second_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=graph.seq.length, y=steps.per.sec, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_steps.per.second_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_steps.per.second_vs_seq.length_logXY.png", width=9.3, height=4.71) 

ggplot(bdsg.prof, aes(x=graph.seq.length, y=build.mem*1000, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_build.mem_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_build.mem_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=graph.seq.length, y=build.time, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_build.time_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_build.time_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=graph.seq.length, y=load.mem*1000, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_load.mem_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_load.mem_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=graph.seq.length, y=load.time, color=graph.model)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_load.time_vs_seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_load.time_vs_seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=build.time, y=load.time, color=graph.model, size=graph.seq.length)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_load_time_vs_build_time_size=seq.length_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_load_time_vs_build_time_size=seq.length_logXY.png", width=9.3, height=4.71)

ggplot(bdsg.prof, aes(x=build.time, y=load.time, color=graph.model, size=graph.avg.path.depth)) + geom_point() + scale_x_log10() + scale_y_log10() + theme_bw()
ggsave("bdsg.prof_load_time_vs_build_time_size=avg.path.depth_logXY.pdf", width=9.3, height=4.71)
ggsave("bdsg.prof_load_time_vs_build_time_size=avg.path.depth_logXY.png", width=9.3, height=4.71)
