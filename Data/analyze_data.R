library(tidyverse)
library(ggrepel)
library(fixest)
library(huxtable)

results.queer <- read.csv("Final/results_queer.csv")

results.queer %>% 
  ggplot(aes(x=queer.players, y=Success.Index))+
  geom_point()+
  geom_text_repel(aes(label=Country),
            nudge_y=2.5,
            nudge_x=0.5,
            size=3,
            check_overlap=T)+
  geom_smooth(method="lm")+
  facet_wrap(~Year)+
  labs(title="Queer Players and World Cup Success",
       x="Number of Queer Players",
       y="Success Score")
ggsave(last_plot(),
       filename="queer-success.png",
       path="..\\Figures\\",
       width=850, height=550, unit="px",
       dpi=100) 

m1 <- feols(Success.Index ~ queer.players | Country+Year, data=results.queer)
huxreg(m1)
