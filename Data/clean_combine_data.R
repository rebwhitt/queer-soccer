library(tidyverse)

rawpath <- "./Raw/"
intpath <- "./Interim/"
finpath <- "./Final/"

## Results

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
write.csv(groupstage, file=paste(intpath,"groupstage.csv",sep=""), row.names=F)

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
write.csv(winners, file=paste(intpath,"winners.csv",sep=""), row.names=F)

knockouts <- lapply(
  paste(rawpath,list.files(path=rawpath, pattern="knockout_wc.*"),sep=""),
  function(f){
    read.csv(f) %>% 
      mutate(Year=as.numeric(str_extract(f,"[0-9]+")))
  }) %>% 
  bind_rows() %>% 
  pivot_wider(names_from="Stage",values_from="Stage") %>% 
  rename(Semi.finals=`Semi-finals`,
         Quarter.finals=`Quarter-finals`) %>% 
  mutate(Semi.finals=ifelse(is.na(Semi.finals),0,1),
         `Quarter.finals`=ifelse(is.na(Quarter.finals),0,1))

write.csv(knockouts, file=paste(intpath,"knockouts.csv",sep=""), row.names=F)


results <- winners %>% 
  full_join(groupstage, by=c("Country","Year")) %>% 
  left_join(knockouts, by=c("Country","Year")) %>% 
  mutate(
    Place = ifelse(is.na(Place),
                   5,
                   Place),
    Semi.finals=ifelse(is.na(Semi.finals),0,Semi.finals),
    Quarter.finals=ifelse(is.na(Quarter.finals),0,Quarter.finals),
    Success.Index=Points+(4*Quarter.finals)+(8*Semi.finals)+(2^(5-Place)))

write.csv(results, file=paste(intpath,"results.csv",sep=""), row.names=F)


## Queer Players

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

wiki.gays <- read.csv(paste(rawpath,"queerlist_wiki.csv",sep="")) %>% 
  filter((!str_detect(Name, "Help|About|Wiki|Main|Content|Current|Random|Learn|Community")&
            !str_detect(Name, "Log in|Contact|Recent|Upload|Special|Create|Donate")&
            !str_detect(Name, "Article|Download|Read|Edit|View|Cite| links?|Get|Print|Talk")&
            !str_detect(Name, "Relate|Page info|Top|CS1|LGBTQ|Lists of|Incomplete|Code")&
            !str_detect(Name, "Privacy|Disclaimer|Developer|Statistic|Cookie st|Mobile|This pa")&
            !str_detect(Name,"^[\t\n ]*[0-9\\.]+"))) %>% 
  mutate(Name = gsub("(^ +|[\n\t\xc2\xa0]*)","",Name),
         Name = gsub("\\[[0-9]+\\]","",Name),
         Name = gsub("( \\(alternate\\)| \\(captain\\)| \\(Brazilian footballer\\))","",Name),
         Name = trimws(Name),
         Name = case_match(Name,
                           "Brianna Scurry"~"Briana Scurry",
                           .default=Name
         ),
         Queer=1) %>% 
  distinct()
write.csv(wiki.gays, file=paste(intpath,"wiki_queerlist.csv",sep=""), row.names=F)

wcrosters <- lapply(
  paste(rawpath,list.files(path=rawpath, pattern="roster_wc.*"),sep=""),
  function(f){
    read.csv(f) %>% 
      mutate(Year=as.numeric(str_extract(f,"[0-9]+")))
  }) %>% 
  bind_rows() %>% 
  filter(Name!="Player") %>% 
  mutate(Name = gsub("( \\((co-)?captain\\)|\\[note 1\\])","", Name),
         Country = case_match(Country,
                      "China PR" ~ "China",
                      .default = Country
                              ))
write.csv(wcrosters, file=paste(intpath,"rosters_wc.csv",sep=""), row.names=F)


roster.gays <- wcrosters %>% 
  full_join(wiki.gays, by="Name") %>% 
  mutate(Queer = ifelse(is.na(Queer),
                        0,
                        Queer),
         Country=case_match(Country,
                            "Republic of Ireland"~"Ireland",
                            .default=Country
         )) %>% 
  filter(!is.na(Country))
write.csv(roster.gays, file=paste(intpath,"rosters_wc_queerlist.csv",sep=""), row.names=F)

all.gays <- gays %>% 
  mutate(Queer = 1,
         Name=gsub("’","'",Name),
         Country=case_match(Country,
                    "Republic of Ireland"~"Ireland"  ,
                    .default=Country
                            )) %>% 
  full_join(roster.gays,
            by=c("Name","Year","Country"),
            relationship = "many-to-many") %>% 
  mutate(Queer = case_when(
    Queer.x ==1 & Queer.y==0 ~ 1,
    TRUE ~ Queer.y
  )) %>% 
  filter(!is.na(Queer)) %>% 
  select(Name, Year, Country, Club, Queer)

## Combine 

results.queer <- all.gays %>% 
  group_by(Country, Year) %>% 
  summarize(queer.players = sum(Queer)) %>% 
  ungroup() %>% 
  full_join(results, by=c("Country","Year"))
write.csv(results.queer, file=paste(finpath,"results_queer.csv",sep=""), row.names=F)


###################
winners.comb %>% 
  filter(Year >=2015) %>% 
  ggplot(aes(y=Success.Index, x=n.gays, color=Year))+
  geom_point(alpha=0.5)+
  geom_smooth(method="lm")

roster.gays %>% 
  ggplot(aes(x=Country, y=Queer))+
  stat_summary(geom="bar")+
  facet_wrap(~Year)

roster.gays %>% 
  ggplot(aes(x=Year, y=Queer))+
  stat_summary(fun="mean", geom="bar")

gsub("^[\t\n]+ *","",gays[17,2])
gays[17,2]

as.character.hexmode(gays[17,2])
substr(gays[17,2],1,1)
charToRaw(substr(gays[17,2],1,1))
charToRaw("\xc2\xa0")
