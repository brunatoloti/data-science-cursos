# Instalando e importando bibliotecas
install.packages("dplyr")
library(dplyr)
install.packages("ggplot2")
library(ggplot2)

# Declarando o caminho do arquivo a ser analisado
# Arquivo disponibilizado pelo curso e que se refere a um conjunto de dados da Play Store
path <- "C:/Users/Admin/Documents/Data Visualization - Gr�ficos com uma vari�vel/Parte 1/googleplaystore.csv"

# Lendo o arquivo e salvando seus registros na vari�vel dados
dados <-  read.csv(file = path, stringsAsFactors = FALSE)

# Visualizando os registros do conjunto de dados
View(dados)

# Visualizando as 6 primeiras linhas do conjunto de dados
head(dados)

# Visualizando as 6 �ltimas linhas do conjunto de dados
tail(dados)

# Visualizando o tipo de vari�vel de cada coluna do conjunto de dados
str(dados) # Fun��o an�loga ao describe() do Python

# Fazendo algumas an�lises gr�ficas

# Como est�o as avalia��es das aplica��es da loja do Google?
hist(dados$Rating) # Utilizando uma fun��o nativa do R para constru��o do histograma
# Gerando o gr�fico, n�o conseguimos ver o valor m�nimo, mas conseguimos ver que 
# aparecem Ratings irrelevantes, dado que sabemos que as notas v�o de 1 a 5

# Para verificarmos as frequ�ncias e os valores m�ximo e m�nimo, podemos usar 
# a fun��o table()
table(dados$Rating)
# Fazendo isso, conseguimos ver que, de fato, o valor m�nimo � 1, por�m o valor
# m�ximo � 19  e possui uma frequ�ncia de 1. Como sabemos que, na verdade, o 
# valor m�ximo � 5, podemos concluir que essa nota 19, que foi inserida apenas
# 1 vez, � um erro. Podemos remover essa linha do conjunto de dados.

# Mas, antes disso, mudando o layout do gr�fico de forma que n�o tenhamos esse
# problema. Dado que j� sabemos que as notas v�o de 1 a 5, j� colocamos como
# par�metro o xlim que recebe um vetor de 1 a 5 que limita o eixo x a apenas 
# esses valores.
hist(dados$Rating, xlim = c(1,5))

# Gerando o gr�fico com ggplot
rating.Histogram <- ggplot(data = dados) + geom_histogram(mapping = aes(x = Rating), 
                                                          na.rm = TRUE,
                                                          breaks = seq(1,5)) + xlim(c(1,5))
rating.Histogram <- rating.Histogram + ggtitle("Histograma das Notas") + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) 
rating.Histogram

# Quais as categorias de aplicativos que est�o em maior quantidade e 
# menor quantidade na loja?
ggplot(data = dados) + geom_bar(mapping = aes(x = Category), stat = 'count')
#stat: a pr�pria fun��o ir� fazer a contagem de cada categoria, semelhante 
# � tabela de frequ�ncia? Ou ser� indicada essa contagem para ser plotada? Nesse
# caso, a pr�pria fun��o far� a contagem de cada categoria, por isso, stat='count'

# Gerando o gr�fico, podemos notar que n�o h� como ler os nomes das categorias.
# Dessa forma, precisamos melhorar o gr�fico de forma que fique leg�veis as 
# informa��es
# Para isso, passaremos de um gr�fico de barras verticais para um de barras
# horizontais. Faremos isso, passando os ticks do eixo x para o eixo y e as
# contagens do eixo y para o eixo x, usando a fun��o coord_flip()
ggplot(data = dados) + geom_bar(mapping = aes(x = Category), stat = 'count') + coord_flip()

# Fazendo uma ordena��o das categorias de acordo com a quantidade no conjunto de dados
# Criando um df com as frequ�ncias simples de cada categoria
category.Freq <- data.frame(table(dados$Category))
# Gerando o gr�fico utilizando esse subconjunto de dados gerado anteriormente
# Aqui nesse gr�fico, a contagem ser� fornecida, por isso, stat='identity'
ggplot(data = category.Freq) + geom_bar(mapping = aes(x = reorder(Var1, Freq), y = Freq), 
                                        stat = 'identity') + coord_flip()

# Podemos visualizar apenas as 10 categorias que possuem mais aplicativos 
category.Top10 <- category.Freq[(order(-category.Freq$Freq)),]
category.Top10 <- category.Top10[1:10, ]
freq.Category.Plot <- ggplot(data = category.Top10) + geom_bar(mapping = aes(x = reorder(Var1, Freq), y = Freq), 
                                        stat = 'identity') + coord_flip()
freq.Category.Plot <- freq.Category.Plot + ggtitle('As 10 categorias com mais apps') +
  xlab('Categoria') + ylab('Quantidade') + 
  geom_bar(aes(Var1, Freq), fill = 'darkcyan', stat = 'identity') + 
  theme_bw()
freq.Category.Plot

# Fazendo corre��o de dados.
# Quando geramos o gr�fico com a frequ�ncia das categorias na loja, conseguimos
# ver que havia uma categoria com nome '1.9', com frequ�ncia 1,
# o que n�o faz muito sentido.
# Al�m disso, podemos lembrar que havia um erro no Ratings, pois havia uma nota 19,
# sendo que as notas v�o de 1 a 5, apenas. Portanto, podemos concluir que essa
# categoria '1.9' tamb�m se trata de um erro.
# Criando um subconjunto do conjunto original sem a linha onde categoria � '1.9'
dados2 <- dados %>% filter(Category != '1.9')

# J� que foi removida a categoria '1.9', ser� feita uma nova verifica��o do 
# atributo Ratings, verificando o valor m�nimo e m�ximo
min(dados2$Rating)
max(dados2$Rating)
# Obtivemos como resultado 'NaN'. Ou seja, h� registros sem valores no conjunto de dados
# Mas, quantos registros est�o sem valores?
dados2 %>% filter(is.na(Rating)) %>% count()
# Temos 1474 registros NA's na coluna Rating
# Podemos verificar isso de outra forma
summary(dados2$Rating)
# A partir dessa fun��o summary() j� conseguimos ver tamb�m os valores m�nimo e
# m�ximo, tirando esses valores NA's

# Mais de 10% dos dados possui Rating NA, um n�mero consider�vel de valores faltantes.
# Corrigindo os registros faltantes usando a m�dia
mean.Category <- dados2 %>% filter(!is.na(Rating)) %>% 
  group_by(Category) %>% 
  summarise(media = mean(Rating)) #Criando um novo conjunto com os valores de m�dia

for (i in 1:nrow(dados2)){
  if (is.na(dados2[i, 'Rating'])){
    dados2[i, 'newRating'] <- mean.Category[mean.Category$Category == dados2[i, 'Category'],'media']
  }else{
    dados2[i, 'newRating'] <- dados2[i, 'Rating']
  }
}
# Verificando agora o n�mero de valores NA's e valores m�ximo e m�nimo
summary(dados2$newRating)
# De outra forma
min(dados2$newRating)
max(dados2$newRating)
dados2 %>% filter(is.na(newRating)) %>% count()


# Criando r�tulos, novos atributos
# Dado que os dados j� foram corrigidos, agora ser�o criados r�tulos para os 
# valores presentes em newRating, de forma que:
# newRating <= 2: 'ruim'
# newRating >= 4: 'bom'
# 2.1 < newRating < 3.9: 'regular'

dados2 <- dados2 %>% 
            mutate(Ratingclass = if_else(newRating <= 2, 'ruim',
                                 if_else(newRating >= 4, 'bom',
                                         'regular')))  #mutate cria uma nova coluna no conjunto

# Gerando um gr�fico com essas novas informa��es, com esses r�tulos
RatingClass.Plot <- ggplot(dados2) + geom_bar(aes(Ratingclass), stat = 'count') +
  ggtitle('Quantidade de notas por classe') + 
  xlab('Classe') +
  ylab('Quantidade') +
  geom_bar(aes(Ratingclass), fill = c('green4', 'yellow2', 'red')) +
  theme_bw()
RatingClass.Plot

# Gerando um gr�fico de pizza para visualizarmos a propor��o do tipo de aplicativo,
# ou seja, a propor��o de apps pagos e n�o pagos
# Como temos apenas dois tipos diferentes de aplicativos, o gr�fico de pizza ser� usado
type.Freq <- data.frame(table(dados2$Type))

type.Freq.Plot <- ggplot(type.Freq) + geom_bar(aes(x = '', y = Freq, fill = Var1), 
                                               stat = 'identity',
                                               width = 1) +
                    coord_polar(theta = 'y', start = 0) #altera o formato da barra
#Melhorando esse gr�fico
blank_theme <- theme_minimal() +
               theme(
                 axis.title.x = element_blank(),
                 axis.title.y = element_blank(),
                 panel.border = element_blank(),
                 panel.grid = element_blank(),
                 axis.ticks = element_blank(),
                 axis.text.x = element_blank()
               )
type.Freq.Plot <- type.Freq.Plot + blank_theme
# Importando a biblioteca scales
library(scales)
type.Freq.Plot <- type.Freq.Plot + geom_text(aes(x = '', y = Freq/2,
                                                 label = percent(Freq/sum(Freq))), size = 3) +
                                   scale_fill_discrete(name = 'Tipo App') + #Mudar a legenda
                                   ggtitle('Propor��o dos tipos de App') +
                                   theme(plot.title = element_text(hjust = 0.5))
                  
type.Freq.Plot

# O que podemos concluir sobre o tamanho de download e instala��o dos aplicativos?
str(dados2)
# Olhando o tipo de dado na coluna Size, podemos ver que � do tipo chr, ou seja,
# n�o � num�rica. Teoricamente, deveria ser num�rica, porque deveria armazenar
# apenas o tamanho do aplicativo, por�m, possui letras junto com n�meros nos seus valores.
# Conseguimos ver, pelos exemplos iniciais que a str() d�, que h� valores armazenando
# M nos registros (megabytes). Por�m, h� outros tipos de valores que devem ser
# tratados nessa coluna?
# Fazendo uma tabela de frequ�ncia para verificar isso
freq.Size <- data.frame(table(dados2$Size))
freq.Size
# Ao explorar essa tabela de frequ�ncia, foi poss�vel identificar que os tamanhos
# dos aplicativos s�o indicados como kilobytes, pela letra k, ou megabytes, pela 
# letra M. Al�m disso, temos valores como Varies with device, que nos indica que
# o tamanho depende do dispositivo.

# Transformando esses valores, convertendo-os para a mesma escala (aqui, kilobytes)
# Verificando a ocorr�ncia de K ou M nos registros
# Se tiver K no registro, apenas elimina a letra; se tiver M no registro, faz a convers�o
# de megabyte para kilobyte (1K = 1024M)

# Exemplo com 1 string de teste
teste <- dados2$Size[1]
grepl(pattern = 'M', x = teste, ignore.case = T) # Ocorrencia de M em teste?
grepl(pattern = 'K', x = teste, ignore.case = T) # Ocorrencia de K em teste?
gsub(pattern = 'M', replacement = '--', x = teste, ignore.case = T) # Substituicao de M por --
gsub(pattern = 'K', replacement = '--', x = teste, ignore.case = T) # Substituicao de K por --

# Aplicando para a coluna inteira
dados2$kb <- sapply(X = dados2$Size, FUN = function(y){
  if (grepl('M', y, ignore.case = T)){
    y <- as.numeric(gsub(pattern = 'M', replacement = '', x = y, ignore.case = T))*1024
  }else if (grepl('K|\\+', y, ignore.case = T)){
    y <- as.numeric(gsub(pattern = 'K|\\+', replacement = '', x = y, ignore.case = T))
  }else{
    y <- 'nd'
  }
})

hist(as.numeric(dados2$kb))
# Resolvendo o problema do eixo x para que n�o fique mais em nota��o cient�fica
options(scipen = 999)
# Gerando o histograma mais uma vez
hist(as.numeric(dados2$kb))

# Removendo os registros nd e convertendo a coluna para o tipo num�rico, colocando 
# em um novo conjunto de dados essas mudan�as (importante manter os dados originais,
# dessa forma, criar um novo conjunto de dados com mudan�as, faz sentido)
size.app <- dados2 %>% filter(kb != 'nd') %>% mutate(kb = as.numeric(kb))
# Gerando um gr�fico desse novo conjunto de dados
size.App.Plot <- ggplot(size.app) + geom_histogram(aes(kb)) +
  ggtitle('Histograma do tamanho dos aplicativos') +
  geom_histogram(aes(kb, fill = ..x..)) +
  scale_fill_gradient(low='blue', high = 'yellow') + 
  guides(fill = FALSE) +
  xlab('Tamanho do App (em kb)') + 
  ylab('Quantidade de Apps') +
  theme_bw()
size.App.Plot


# Fazendo an�lises em outra base de dados
# Base fornecida pelo curso
# Com essa base de dados, o intuito � elaborar um gr�fico para apresentar 
# informa��es sobre a nota de avalia��o atrav�s do tempo
# Importando a base de dados
notas <- read.csv('C:/Users/Admin/Documents/Data Visualization - Gr�ficos com uma vari�vel/Parte 1/user_reviews.csv')

# Explorando a base de dados
str(notas)

# Para trabalhar com data e hora, usaremos o pacote lubridate
# Instalando o pacote
install.packages("lubridate")
library(lubridate)

# Pelo str(notas) feito, conseguimos ver que a coluna data � do tipo chr. 
# Precisamos transform�-la em tipo datetime
notas$data_2 <- ymd_hms(notas$data)
str(notas)

# Criando o gr�fico
ggplot(notas) + geom_line(aes(x = data_2, y = Sentiment_Polarity))
# O gr�fico ficou ruim, sem interpreta��o

# Melhorando o gr�fico
# Ficando apenas com ano e m�s na coluna data_2
notas$data_2 <- parse_date_time(format(notas$data_2, '%Y-%m'), 'ym')

# Criando o mesmo gr�fico para ver se melhorou um pouco
ggplot(notas) + geom_line(aes(x = data_2, y = Sentiment_Polarity))
# O gr�fico est� menos polu�do, mas ainda ruim

# Calculando a m�dia de Sentiment_Polarity para cada m�s-ano
media_polaridade <- notas %>% group_by(data_2) %>% summarise(media = mean(Sentiment_Polarity))

# Criando o gr�fico
polaridade_plot <- ggplot(media_polaridade) + geom_line(aes(x = data_2, y = media), color = "darkcyan") +
  ggtitle('M�dia das polaridades dos sentimentos por m�s-ano') +
  xlab('M�s-Ano') +
  ylab('M�dia das polaridades') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
polaridade_plot

# Fazendo um dashboard com todos os gr�ficos
# Instalando e carregando a biblioteca 
install.packages("gridExtra")
library(gridExtra)

grid.arrange(rating.Histogram, freq.Category.Plot, type.Freq.Plot,
             size.App.Plot, RatingClass.Plot, polaridade_plot,
             nrow = 2, ncol = 3)

