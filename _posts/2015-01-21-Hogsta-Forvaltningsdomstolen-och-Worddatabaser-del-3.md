---
title: 'Att skapa en databas från Wordfiler: städa upp i databasen'
date: '2015-01-26'
author: LCHansson
layout: post
tags: [R, scraping, databases]
comments: yes
lang: se
---

_Detta är den andra artikeln i en serie fristående artiklar som jag skrev i början av 2015 med anledning av en diskussion som uppstått kring Personuppgiftslagen (PUL) och vad som är en "databas" i lagens bemärkelse. Artiklarna är löst tematiskt sammanhållna och behandlar var för sig praktiska, juridiska och programmeringstekniska aspekter av hur man mycket enkelt kan använda en uppsättning Wordfiler som en fullt fungerande databas._

_Läs även gärna de övriga artiklarna i serien:_

1. [PUL och Worddatabaser](http://lchansson.com/blog/2015/01/Hogsta-Forvaltningsdomstolen-och-Worddatabaser-del-1/) (juridiska och politiska aspekter)
2. [Att skapa en databas från Wordfiler: Läsa in data](http://lchansson.com/blog/2015/01/Hogsta-Forvaltningsdomstolen-och-Worddatabaser-del-2/) (programmering och datainläsning)
3. Att skapa en databas från Wordfiler: städa upp i databasen (databearbetning)
4. Efterord: Liberal tolkning av PUL och bristande teknisk kunskap hos svenska domstolar? (kommer inom kort)


## Inledning

I tidigare inlägg har jag diskuterat hur enkelt det är att sätta upp en databas bestående av ett antal wordfiler med hjälp av lite enkla scraping-verktyg. Men den databas vi tog fram [senast](http://lchansson.com/blog/2015/01/Hogsta-Forvaltningsdomstolen-och-Worddatabaser-del-2/) är visserligen fullständig, men ganska rörig. I denna artikel visar jag hur man snabbt kan skapa lite struktur i en sådan, förhållningsvis ostrukturerad databas. Precis som i föregående inlägg kommer jag att använda mig av **R** för att visa hur detta kan gå till.


## Skapa [tidy data](http://vita.had.co.nz/papers/tidy-data.pdf)

Den dokumentdatabas vi skapade i förra inlägget har tre kolumner: `docnum`, som fungerar som primärnyckel i databasen, `header` och `text`.

Vi börjar med att titta närmare på `header`-kolumnen. Den visar oss vilka rubriker som finns i de olika dokumenten. Låt oss se vilka som ingår i varje dokument:


{% highlight r %}
by(dokumentdata, dokumentdata$docnum, FUN = function(x) unique(x$header))
{% endhighlight %}



{% highlight text %}
> Error in by(dokumentdata, dokumentdata$docnum, FUN = function(x) unique(x$header)): object 'dokumentdata' not found
{% endhighlight %}

Det finns en del udda data här. Men en gemensam nämnare för nästan samtliga dokument är att de innehåller rubrikerna "Personalia", "Ekonomi", "Brottmål" och "Övrigt". Ett av dokumenten, nr. 4, tycks dock ha ersatt "Ekonomi" med rubrikerna "Årsinkomster" och "Skulder". Men det är inget vi inte kan åtgärda!

Ju större skillnaderna är mellan olika dokument, desto svårare kommer det såklart att bli att extrahera information om samtliga individer i databasen. I denna artikel gör vi antagandet att den information vi är ute efter är den som finns lagrad för samtliga individer, i detta fall uppgifter om personer, deras ekonomi (vi avgränsar oss till årsinkomster) och deras inblandning i brottmål. Dessutom kommer vi att spara alla eventuella kommentarer under "Övrigt" som en textsträng. Men vi hade lika gärna kunna varit ute efter andra data - ladda gärna ned dokumenten från mitt [GitHub-repo](https://github.com/LCHansson/541_17-exempel) och sök igenom dem själv!

Det viktiga nu är att skapa sig en uppfattning om hur data kan tänkas se ut. `text`-kolumnen innehåller hela stycken ur de olika Worddokumenten. Vilka är relevanta, och vad kan vi utvinna för information ur dem? För att kunna svara på dessa frågor behöver vi extrahera data kategori för kategori och undersöka dem lite närmare, och eventuellt göra mindre justeringar innan vi slutligen sparar data i färdiga relationstabeller.

Nu återstår bara att söka igenom databasen kategori för kategori och spara data i ett lättläst och "tidy" format.

#### Personalia

Vi börjar med den lättaste kategorin - personalia. Först plockar vi ut enbart de rader som har `header == "Personalia"`:


{% highlight r %}
personalia_raw <- dokumentdata %>%
  filter(header == "Personalia") %>%
  group_by(docnum)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}



{% highlight r %}
print(personalia_raw, n = 12)
{% endhighlight %}



{% highlight text %}
> Error in print(personalia_raw, n = 12): object 'personalia_raw' not found
{% endhighlight %}

Personalia tycks vara ganska enhetligt strukturerade. Rader med namn tycks ofta (alltid?) inledas med texten "Namn:", och personnummer följer alltid formatet YYMMDD-XXXX. Vi kan därför extrahera `namn` och `personnr` med hjälp av ytterligare filtrering och perl-liknande reguljära uttryck genom att söka efter de mönster jag beskrev ovan:


{% highlight r %}
namn <- personalia_raw %>%
  filter(str_detect(text, "namn" %>% ignore.case())) %>%
  mutate(
    # Extract all characters following the string "Namn:"
    namn = str_extract_all(text, "(?<=namn:).*" %>% perl() %>% ignore.case())[[1]] %>%
      # and then remove surrounding whitespace
      str_trim()
  ) %>%
  select(docnum, namn)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}



{% highlight r %}
personnr <- personalia_raw %>%
  filter(str_detect(text, "\\d{6}-\\d{4}" %>% perl())) %>%
  # Extract strings on the form DDDDDD-DDDD
  mutate(personnr = str_extract_all(text, "\\d{6}-\\d{4}" %>% perl())[[1]]) %>%
  select(docnum, personnr)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

Vi kan nu upprepa denna procedur för alla uppgifter vi är intresserade av.


#### Ekonomi

Nästa steg är uppgifter om årsinkomster. Som vi såg ovan innehåller alla dokument utom ett rubriken "Ekonomi", medan ett av dokumenten istället hade rubriken "Årsinkomster". Vi måste alltså ta med båda två dessa i vår sökning.

Precis som ovan börjar vi med att extrahera all ekonomidata och titta närmare på den:


{% highlight r %}
ekonomi_raw <- dokumentdata %>%
  filter(header == "Ekonomi" | header == "Årsinkomster") %>%
  group_by(docnum)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}



{% highlight r %}
ekonomi_raw$text
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): object 'ekonomi_raw' not found
{% endhighlight %}

Vi kan notera fyra saker om vårt data:

1. I vårt data har inkomstuppgifter alltid fem eller sex siffror, och ibland används ett mellanslag som tusentalsavgränsare.
2. Årsuppgifter är alltid fyra siffror långa och börjar alltid med "20".
3. Inkomstuppgifter och årsuppgifter förekommer alltid på samma rad.
4. Rad 17 har fem inkomstuppgifter OCH årsuppgifter på samma rad. Vi måste separera dessa till fem olika rader innan vi kan lagra dem i vårt dataset.

Vi börjar med att extrahera data för alla dokument utom nummer 5, där raden med fem inkomstuppgifter finns.


{% highlight r %}
# Extract income data
inkomster <- ekonomi_raw %>%
  filter(str_detect(text, "\\d{2,3}(\\s)?\\d{3}" %>% perl())) %>%
  mutate(
    ar = str_extract(text, "20\\d{2}" %>% perl()),
    inkomst = str_extract(text, "\\d{2,3}(\\s)?\\d{3}" %>% perl())
  )
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

Vi fortsätter sedan med att separera inkomstuppgifter för dokument nr 5 och sedan lägga till dem till vårt nyskapade dataset.


{% highlight r %}
# Separate the single row for document 5 into five separate rows
ink5 <- ekonomi_raw$text[ekonomi_raw$docnum == 5][[1]]
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): object 'ekonomi_raw' not found
{% endhighlight %}



{% highlight r %}
yrs <- str_extract_all(ink5, "(?<=\\()\\d{4}(?=\\))" %>% perl())[[1]]
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "str_extract_all"
{% endhighlight %}



{% highlight r %}
ink <- str_extract_all(ink5, "\\d{2,3}(\\s)?\\d{3}" %>% perl())[[1]]
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "str_extract_all"
{% endhighlight %}



{% highlight r %}
inkomster_5 <- data_frame(
  docnum = 5,
  ar = yrs,
  inkomst = ink,
  header = "Ekonomi"
)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "data_frame"
{% endhighlight %}



{% highlight r %}
# Replace data for document 5 with the munged data
# and convert the string "XXX XXX" into an integer
inkomster <- inkomster %>%
  filter(!is.na(ar), docnum != 5) %>%
  bind_rows(inkomster_5) %>%
  select(-text, -header) %>%
  mutate(inkomst = inkomst %>% str_replace_all("[[:blank:]]", "") %>% as.integer())
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

#### Brottmål

Vi upprepar proceduren för brottmålsinblandning:


{% highlight r %}
## Brottmål
brottmal_raw <- dokumentdata %>%
  filter(header == "Brottmål") %>%
  group_by(docnum)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}



{% highlight r %}
brottmal_raw$text
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): object 'brottmal_raw' not found
{% endhighlight %}

Det här datat har helt klart en hel del brödtext i sig. Denna hade kunnat vara intressant i något annat sammanhang men just nu är vi som sagt bara intresserade av att veta vilka brottmål personerna varit inblandade i.

Jag har ingen som helst aning om hur ett register över inblandning i brottmål kan tänkas se ut i verkligheten, men mitt intryck är att brottmålen som registreras i just dessa dokument alltid är diarieförda med en kod på formatet [X]XX-XXX, alltså två eller tre siffror följda av ett mellanslag och sen tre siffror till. Vi extraherar därför dessa data:


{% highlight r %}
# Filter out court cases
brottmal <- brottmal_raw %>%
  filter(str_detect(text, "\\d{3}-\\d{2,3}")) %>%
  mutate(inblandad_i_mal = str_extract(text, "\\d{3}-\\d{2,3}")) %>%
  select(docnum, inblandad_i_mal)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

#### Kommentarer

Slutligen extraherar vi också all text som finns lagrad under "Övrigt" i dokumenten, mest för att visa att vi kan:


{% highlight r %}
ovrigt <- dokumentdata %>%
  filter(header == "Övrigt") %>%
  select(docnum, kommentar = text)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

## Sammanställning av samtliga data till en databas

Nu är vi nästan klara! Allt vi behöver göra är att lägga ihop alla de små prydliga dataset vi just skapat till en riktig, välstrukturerad databas. Som tur är har vi använt variabeln `docnum` som nyckel när vi skapat alla våra småtabeller, så vi kan återanvända den för att skapa en sorts primärnyckel i vår databas.


{% highlight r %}
# Put everything together into a proper database
persondatabas <- namn %>%
  left_join(personnr, by = "docnum") %>%
  left_join(ovrigt, by = "docnum")
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

För att se uppgifter om ekonomi eller brottmålsinblandning får vi lägga till dessa också, men om vi gör detta tappar vi principen "ett dokument, en rad". Nedan ger jag ändå ett exempel på hur man kan göra om man vill följa principen om att lagra _alla_ data i ett och samma dataset.


{% highlight r %}
# Adding income and court case data creates more than one row per person
persondatabas_stor <- persondatabas %>%
  left_join(inkomster, by = "docnum") %>%
  left_join(brottmal, by = "docnum")
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}


Och voila! Vi har nu skapat vår egen prydliga, välstrukturerade databas med data uppdelade per person. Databsen har en primärnyckel, är trevlig att titta på och lätt att söka i.

Som avslutning kan vi titta på två exempel på hur en sådan databas skulle kunna användas på "riktigt", t.ex. för att göra olika typer av integritetskränkande sökningar. Låt oss först anta att vi vill veta vem som hade högst och lägst inkomster av alla personer i databasen. Vi utgår då från den senaste kända inkomstuppgiften för varje person:


{% highlight r %}
persondatabas %>%
  # Only keep the columns we're interested in
  select(-kommentar) %>%
  # Join with income data
  left_join(inkomster, by = "docnum") %>%
  # Last year per person only
  filter(ar == max(ar)) %>%
  # Only keep top and bottom income holders
  ungroup() %>%
  filter(inkomst == max(inkomst) | inkomst == min(inkomst))
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

Vildsvin Vildsvinsdotter är alltså den person med den högsta inkomsten i databasen, och Charlie Charlieberg är den med lägst inkomst.

Som ett andra exempel, låt oss anta att vi vill göra en scatter plot över relationen mellan inkomst och hur många brottmål man varit inblandad i. I detta fall använder vi oss av genomsnittet av personernas kända årsinkomster istället. 


{% highlight r %}
library("ggplot2")
{% endhighlight %}



{% highlight text %}
> Loading required package: methods
{% endhighlight %}



{% highlight r %}
library("scales")
persondatabas %>%
  group_by(docnum, namn, personnr) %>%
  select(-kommentar) %>%
  left_join(inkomster, by = "docnum") %>%
  summarise(medelinkomst = mean(inkomst)) %>%
  left_join(brottmal, by = "docnum") %>%
  group_by(docnum, namn, personnr, medelinkomst) %>%
  summarise(antal_brottmal = sum(!is.na(inblandad_i_mal))) %>%
  ggplot(aes(x = medelinkomst, y = antal_brottmal, color = namn)) +
  geom_point(size = 10) +
  labs(title = "Medelinkomst vs inblandning i brottmål (fiktiva data)", x = "Medelinkomst", y = "Antal brottmål 2010-2014") +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(labels = comma)
{% endhighlight %}



{% highlight text %}
> Error in eval(expr, envir, enclos): could not find function "%>%"
{% endhighlight %}

Så de med lägst _och_ högst inkomster i databasen är alltså de som varit inblandade i flest brottmål. Intressant!


## Avrundning

Mitt experiment där jag försökte använda en samling Worddokument som en databas är avslutat. Resultatet: det är ungefär lika enkelt att använda Worddokument som databas som det är att scrapa en webbsida, eller att lära sig lite SQL och skriva några queries. Koden i detta och föregående inlägg tog mig i runda slängar 3 timmar att skriva inklusive felsökning.

Avsikten har varit att ge ett konkret, förhoppningsvis lättläst exempel på detta. Det finns naturligtvis flera. Som jag nämnde i inledningen av detta experiment finns det nog många som skulle valt ett helt annat tillvägagångssätt men ändå nått ungefär samma, eller ett bättre, resultat.

En av poängerna jag vill göra med detta är att det är viktigt att förhålla sig kritisk till hur svårtillgänglig information faktiskt är bara för att man har lagrat den på ett obskyrt sätt. Jag tror inte att de flesta som arbetar med Worddokument har för avsikt att använda dem som en databas, men icke desto mindre är det _väldigt lätt_ att göra just detta om man bara besitter lite rudimentära programmeringsfärdigheter.

I nästa inlägg ska jag försöka göra mitt bästa för att knyta ihop säcken kring detta resonemang.




