---
title: 'PUL och Worddatabaser'
date: '2015-01-16'
author: LCHansson
layout: post
tags: [R, scraping, databases]
comments: yes
lang: se
---

_Detta är den första artikeln i en serie fristående artiklar som jag skrev i början av 2015 med anledning av en diskussion som uppstått kring Personuppgiftslagen (PUL) och vad som är en "databas" i lagens bemärkelse. Artiklarna är löst tematiskt sammanhållna och behandlar var för sig praktiska, juridiska och programmeringstekniska aspekter av hur man mycket enkelt kan använda en uppsättning Wordfiler som en fullt fungerande databas._

_Läs även gärna de övriga artiklarna i serien:_

1. PUL och Worddatabaser (juridiska och politiska aspekter)
2. [Hur man skapar en databas från Wordfiler](http://lchansson.com/blog/2015/01/Hogsta-Forvaltningsdomstolen-och-Worddatabaser-del-2/) (programmering och datainläsning)
3. [Använda Wordfiler som en sökbar databas, del 2: Städa upp i data](http://lchansson.com/blog/2015/01/Hogsta-Forvaltningsdomstolen-och-Worddatabaser-del-2/) (databearbetning)
4. Efterord: Liberal tolkning av PUL och bristande teknisk kunskap hos svenska domstolar? (kommer inom kort)


## Inledning

Nyligen läste jag om ett avgörande i Högsta Förvaltningsdomstolen [(mål 571-14)](http://www.hogstaforvaltningsdomstolen.se/Domstolar/regeringsratten/Avg%C3%B6randen/2015/Januari/571-14.pdf) där ett företag blivit åtalat av Datainspektionen för att ha brutit mot PUL. Företaget erbjuder kreditupplysningar t.ex. till arbetsgivare vid anställningsintervjuer, och hade byggt upp ett elektroniskt dokumentarkiv bestående av Wordfiler där känsliga uppgifter såsom ekonomiska förhållanden, involvering i brottmål, bolagsengagemant m.m. lagrats om de personer man hade gjort upplysningar på. Arkivet hade strukturen "en person - ett dokument". Till min förvåning hade HFD frikänt företaget från brott mot PUL med hänvisning till en [undantagsregel](https://lagen.nu/1998:204#P5aS1) (§5a) i lagen som medger samlingar av personuppgifter som inte "ingår i eller är avsedda att ingå i en samling av personuppgifter som har strukturerats för att påtagligt underlätta sökning efter eller sammanställning av personuppgifter."

Detta fascinerade mig. Min spontana känsla var att HFD tycktes mena att det är _lagringsmediet_, alltså valet av Wordfiler för att lagra personuppgifter och inte t.ex. en SQL-databas eller en CSV-fil, som gör att detta inte är en databas. Men som vem som helst som arbetat ett tag med datalagring vet, är det ungefär lika lätt att systematiskt utvinna information ur Wordfiler som ur vilken annan databas som helst. Det är till och med lättare i många fall, eftersom det går alldeles utmärkt att utvinna all information man behöver utan någon som helst serverprogramvara eller liknande. Allt som krävs är grundläggande programmeringskunskaper och lite förkunskaper om hur datamaterialet kan tänkas se ut.

Nu är det inte min avsikt med denna artikel att ifrågasätta HFD:s dom, eller deras kompetens att fälla ett avgörande i detta mål. Men domstolens resonemang (som framgår relativt tydligt i det välskrivna domslutet) fascinerade mig ändå. Min avsikt med denna och de följande artiklarna är därför att dels försöka resonera lite kring hur jag tror att HFD resonerat (denna artikel), dels att ge ett enkelt exempel på hur nästan vem som helst själv kan göra för att utvinna information ur en uppsättning Wordfiler (artikel 2) och använda dem som en sökbar databas (artikel 3). Slutligen försöker jag knyta ihop säcken genom att våga mig på att slå ett slag för en strängare tolkning av PUL (artikel 4).


## PUL och databaser

Personuppgiftslagen, PUL, tillkom för att "skydda människor mot att deras personliga integritet kränks genom behandling av personuppgifter (1 § PuL)." [(Lagen.nu)](https://lagen.nu/1998:204#P1S1). Hur de olika begreppen i denna mening ska tolkas, alltså "skydda", "människor", "personlig integritet", "kränkning", "behandling" och "personuppgifter", är såklart en delikat fråga och inget som alltid låter sig avgöras utan vidare.

En viktig aspekt av PUL är såklart hur företag och organisationer får hantera databaser med stora mängder personuppgifter. Ett stort antal företag och svenska myndigheter sitter på databaser som innehåller stora mängder personuppgifter av både icke-känslig och känslig karaktär över stora delar av eller till och med hela befolkningen. Därför är det av central betydelse för många tvistemål om PUL hur definitionen av en databas ser ut och hur den tolkas. Om ett företag hanterar en databas som innehåller personuppgifter omfattas den av PUL, om det inte rör sig om en databas omfattas den inte av PUL, ungefär.

HFD:s resonemang kring hur PUL ska tolkas i just fallet med Wordfiler kan utläsas ur domen ovan (vilket jag rekommenderar den intresserade att göra; den är bara 5 sidor lång och mycket välskriven). Om jag tolkar domen rätt så menar HFD att det är följande procedur som ska användas för att avgöra om något bryter mot PUL:

1. Avgör om det rör sig om "behandling av personuppgifter som helt eller delvis är automatiserad." Om svaret är ja, fortsätt till (2). Om svaret är nej omfattas det _inte_ av PUL.
2. Avgör om de personuppgifter som samlats in "ingår i eller är avsedda att ingå i en samling av
personuppgifter som har strukturerats." Om svaret är ja, fortsätt till (3). Om svaret är nej rör det sig _inte_ om en databas.
3. Avgör "i vad mån strukturen påtagligt underlättar sökning efter eller sammanställning av personuppgifterna". Om svaret är ja rör det sig om en databas som omfattas av PUL. Om svaret är nej rör det sig _inte_ om en personuppgiftsdatabas, eller åtminstone inte en sådan som omfattas av PUL.

Som jag tolkar HFD:s domskäl så resonerar man ungefär såhär: En samling Wordfiler med systematiskt insamlade personuppgifter är att betrakta som åtminstone delvis automatiserad. Eftersom uppgifterna har sparats i Wordfiler med en ganska enhetlig struktur så kan de också anses ingå i en samling personuppgifter som har strukturerats. Återstår frågan om uppgifterna är sammanställda för att "påtagligt underlätta sökning eller sammanställning". Och här kommer alltså HFD till den överraskande slutsatsen att en samling Wordfiler _inte_ är att betrakta som en databas.

Det framgår inte riktigt hur HFD resonerar sig fram till denna slutsats, sannolikt för att domstolen lutar sig mot förarbeten eller tidigare domar som vägleder bedömningen. Om jag får våga mig på att spekulera lite tror jag att det handlar om att HFD, på brutalt enkel svenska, gjort bedömningen att de som handhar den insamlade datan helt enkelt saknar kompetens för att på något sätt systematiskt utvinna information ur samlingen worddokument. Kanske finns det även någon form av integritetsskydd, typ lösenordsskydd på enskilda wordfiler eller på vissa mappar i företags filsystem, som försvårar åtkomst till filerna.


## Wordfiler och databaser

Vid en första påsyn kan detta nog verka vara en vettig bedömning. Men om min tolkning av HFD:s resonemang ovan stämmer så vill jag ändå resa ett par invändningar. I själva verket har både databasteknik och teknik automatiserad insamling av uppgifter från dokument av Wordkaraktär gjort så pass stora landvinningar att steget mellan ett Worddokument och en databas mest är en fråga om prioriteringar och synsätt, inte teknisk plattform eller datalagringsstruktur.

Det mest uppenbara exemplet är nog Wordformatet självt. Moderna Worddokument, alltså **.docx**, är i själva verket ingenting annat än samlinga XML-dokument samlade i en zipfil. Och som alla som någon gång sett ett XML-dokument kan lista ut (HTML är t.ex. en variant av XML), så kan man ganska lätt använda XML-taggar som databasnycklar i någon dokumentdatabasmjukvara, t.ex. [mongoDB](http://www.mongodb.org/).

Men det är också minst lika enkelt att helt enkelt skrapa information från XML-filerna med någon enkel XML-parser och samla denna information i någon tabellform för vidare bearbetning, dvs. en databas som uppfyller HFD:s tredje kriterium ovan. Och för att exemplifiera detta har jag gjort just detta från scratch.

I de följande två artiklarna ska jag försöka ge ett lättfattligt exempel på hur pass enkelt det är att, med grundläggande programmeringskunskaper, systematiskt utvinna information ur en stor samling worddokument. Artiklarna innehåller en hel del programkod skriven i språket **R**. Om du är allergisk mot alla former av programkod kanske det därför är bättre att hoppa direkt till den fjärde och sista artikeln i serien, där jag försöker knyta ihop säcken med ett resonemang om varför en samling Wordfiler absolut, nu och i framtiden, borde betraktas som en sökbar databas alldeles oavsett vem som hanterar den och hur.



