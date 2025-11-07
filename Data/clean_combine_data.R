library(tidyverse)

rawpath <- "./Raw/"

groupstage <- lapply(
  paste(rawpath,list.files(path=rawpath, pattern="groupstage.*"),sep=""),
                     function(f){
                       read.csv(f) %>% 
                         mutate(Year=as.numeric(str_extract(f,"[0-9]+")))
                       }) %>% 
  bind_rows() %>% 
  filter(Country != "Teamvte") %>% 
  mutate(Country = gsub(" \\(H\\)","", Country),
         Goal.Differential=gsub("\\+","",Goal.Differential),
         Goal.Differential=gsub("\\−","-",Goal.Differential),
         across(c(-Country), as.numeric),
         Country=case_match(Country,
                            "Republic of Ireland"~"Ireland",
                            "USA"~"United States",
                            .default=gsub("\xc2\xa0","",Country)))

winners <- read.csv(paste(rawpath,"winners_allyears.csv",sep=""), strip.white = T) %>% 
  #mutate(X.1=gsub("",NA,X.1)) %>% 
  fill(Year, X.1) %>% 
  rename(`1`=Final,
         `2`=X.2,
         `3`=Third.place.playoff,
         `4`=X.5) %>% 
  select(Year, `1`, `2`, `3`, `4`) %>% 
  filter(!(`1` %in% c("Champions","Picture",""))) %>% 
  pivot_longer(cols=c(`1`, `2`, `3`, `4`),
               names_to="Place",
               values_to="Country") %>% 
  mutate(Place=as.numeric(Place))

gays <- lapply(
  paste(rawpath,list.files(path=rawpath, pattern="queerlist.*"),sep=""),
  function(f){
    read.csv(f, strip.white=T) %>% 
      mutate(Year=as.numeric(str_extract(f,"[0-9]+")))
  }) %>% 
  bind_rows() %>% 
  select(-X) %>% 
  filter(Name != "#VALUE!",
         !str_detect(Name, "(Group |Coach)",),
         !str_detect(Country,"coach")) %>% 
  mutate(Country = ifelse(Country=="",
                          gsub("\n*,[ \n]*","", str_extract(Name, ",.*")),
                          Country),
         Name = ifelse(str_detect(Name,","),
           gsub(",","", str_extract(Name, ".*,")),
           Name),
         Country=case_match(Country,
                            "Republic of Ireland"~"Ireland",
                            "USA"~"United States",
                            .default=gsub("\xc2\xa0","",Country))) %>% 
  filter(!is.na(Country))

n.gays <- gays %>% 
  group_by(Country, Year) %>% 
  summarize(n.gays=n())

winners.comb <- winners %>% 
  full_join(n.gays, by=c("Country","Year")) %>% 
  full_join(groupstage, by=c("Country","Year")) %>% 
  mutate(
    Place = ifelse(is.na(Place),
                   5,
                   Place),
    n.gays = ifelse(is.na(n.gays),
                    0,
                    n.gays),
    Success.Index=Points+((5-Place)*5)) %>% 
  select(Year, Country, n.gays, Success.Index, Place, Points)

winners.comb %>% 
  filter(Year >=2015) %>% 
  ggplot(aes(y=Success.Index, x=n.gays, color=Year))+
  geom_point(alpha=0.5)+
  geom_smooth(method="lm")
         
gsub("^[\t\n]+ *","",gays[17,2])
gays[17,2]

as.character.hexmode(gays[17,2])
substr(gays[17,2],1,1)
charToRaw(substr(gays[17,2],1,1))
charToRaw("\xc2\xa0")
