#read in packages
library(ggplot2) 
library(tidyr) 
library(optparse) 

option_list <- list(
  make_option(c('--Q'),action='store',type='character',default=NULL,help='Q estimates from admixture'),
  make_option(c('--out'),action='store',type='character',default=NULL,help='name output file, without extension')) 
  
opt_parser = OptionParser(option_list=option_list) 
opt = parse_args(opt_parser) 

input_file <- opt$Q 
out <- opt$out

#read in data table
tbl=read.table(input_file, header = FALSE) 
colnames(tbl) <- c("Pop", "Sample_ID", "Antipodean", "Gibson's")
tbl_long <- tidyr::pivot_longer(tbl, cols = c("Antipodean", "Gibson's"), names_to = "Ancestry", values_to = "Proportion")

#set colours
colours <- c("#00C19F80", "#FF61C380")
#plot
plot <- ggplot(tbl_long, aes(x = Sample_ID, y = Proportion, fill = Ancestry)) +
  geom_bar(stat = "identity") +
  labs(y = "Admixture proportion") +
  scale_fill_manual(values = colours) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.title.x=element_blank(),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        axis.ticks.x=element_blank(),
        panel.border=element_blank()) +
  scale_x_discrete(labels = NULL) +
  geom_text(data = data.frame(x = c(2.5), label = c("DG")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(9), label = c("MW")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(19.5), label = c("NP")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(33), label = c("OR")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(41.5), label = c("SA")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(53), label = c("AA")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(66.5), label = c("DI")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(77), label = c("MD")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_text(data = data.frame(x = c(85), label = c("MR")),
            aes(x = x, y = 0, label = label),
            vjust = 1.5,
            color = "black",
            size = 4,
            inherit.aes = FALSE) +
  geom_vline(xintercept = 5.5, color = "black", size = 1) +
  geom_vline(xintercept = 12.5, color = "black", size = 1) +
  geom_vline(xintercept = 26.5, color = "black", size = 1) +
  geom_vline(xintercept = 39.5, color = "black", size = 1) +
  geom_vline(xintercept = 43.5, color = "black", size = 1) +
  geom_vline(xintercept = 62.5, color = "black", size = 1) +
  geom_vline(xintercept = 70.5, color = "black", size = 1) +
  geom_vline(xintercept = 83.5, color = "black", size = 1)

ggsave(plot = plot, filename = paste0(out,"/Admixture_K2.png"), dpi = 300, width = 12, height = 6, units = "in")
ggsave(plot = plot, filename = paste0(out,"/Admixture_K2.pdf"), dpi = 300, width = 12, height = 6, units = "in")
