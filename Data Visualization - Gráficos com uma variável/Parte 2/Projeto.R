# An�lise dos Microdados do Enem (2010-2017)

# Importando e carregando as bibliotecas
library(data.table)
library(dplyr)
library(ggplot2)
install.packages('reshape')
library(reshape)

getwd()
setwd('C:/Users/Admin/Documents/Data Visualization - Gr�ficos com uma vari�vel/Parte 2')

# Lendo as bases de dados
# Bases disponibilizadas pelo curso e dispon�veis no site do INEP
enem_2010 <- fread('enem_2010.csv', encoding = 'UTF-8')
enem_2011 <- fread('enem_2011.csv', encoding = 'UTF-8')
enem_2012 <- fread('enem_2012.csv', encoding = 'UTF-8')
enem_2013 <- fread('enem_2013.csv', encoding = 'UTF-8')
enem_2014 <- fread('enem_2014.csv', encoding = 'UTF-8')
enem_2015 <- fread('enem_2015.csv', encoding = 'UTF-8')
enem_2016 <- fread('enem_2016.csv', encoding = 'UTF-8')
enem_2017 <- fread('enem_2017.csv', encoding = 'UTF-8')

# Fazendo um merge de todos esses dataframes
merge_enem <- rbind(enem_2010, enem_2011, enem_2012, enem_2013, enem_2014, enem_2015,
                    enem_2016, enem_2017, fill = TRUE)

# Eliminando as bases que n�o iremos mais utilizar, para liberar mem�ria
rm(enem_2010, enem_2011, enem_2012, enem_2013, enem_2014, enem_2015,
   enem_2016, enem_2017)

# Selecionando apenas as colunas de interesse
colunas <- c('NUMERO_INSCRICAO', 'ANO', 'CO_MUNICIPIO_RESIDENCIA', 'MUNICIPIO_RESIDENCIA',
             'UF_RESIDENCIA', 'UF_ESCOLA', 'IDADE', 'SEXO', 'SITUACAO_CONCLUSAO',
             'BRAILLE', 'MUNICIPIO_PROVA', 'UF_PROVA', 'PRESENCA_CIENCIAS_NATUREZA',
             'PRESENCA_CIENCIAS_HUMANAS', 'PRESENCA_LINGUAGENS_CODIGOS', 
             'PRESENCA_MATEMATICA', 'NOTA_CIENCIAS_NATUREZA', 'NOTA_CIENCIAS_HUMANAS',
             'NOTA_LINGUAGENS_CODIGOS', 'NOTA_MATEMATICA', 'TIPO_LINGUA', 'STATUS_REDACAO',
             'NOTA_REDACAO')

enem <- merge_enem %>% select(all_of(colunas))
rm(merge_enem)

# Visualizando o resumo da base de dados
str(enem)

# Normalizando a coluna sexo
table(enem$SEXO)
# Observe que temos tanto o valor F quanto o valor 1 determinando o sexo feminino 
# (de acordo com o dicion�rio de vari�veis)
# E que temos tanto o valor M quanto o valor 0 determinando o sexo masculino
# (de acordo com o dicion�rio de vari�veis)
# Por isso, para n�o ficar confuso e, tamb�m, n�o ficar com colunas diferentes 
# querendo determinar a mesma coisa, � preciso normalizar
enem$SEXO <- gsub('1', 'FEMININO', enem$SEXO)
enem$SEXO <- gsub('^F$', 'FEMININO', enem$SEXO)
enem$SEXO <- gsub('0', 'MASCULINO', enem$SEXO)
enem$SEXO <- gsub('^M$', 'MASCULINO', enem$SEXO)
table(enem$SEXO)

# Normalizando a coluna tipo_lingua (idioma escolhido pelo aluno)
table(enem$TIPO_LINGUA)
# Observe que temos os valores . (provavelmente, � um erro), o 0 que representa
# Ingl�s (de acordo com o dicion�rio de vari�veis) e o 1 que representa Espanhol
# (de acordo com o dicion�rio de vari�veis)
enem$TIPO_LINGUA <- gsub('0', 'INGL�S', enem$TIPO_LINGUA)
enem$TIPO_LINGUA <- gsub('1', 'ESPANHOL', enem$TIPO_LINGUA)
table(enem$TIPO_LINGUA)

# Verificando a coluna uf_prova
table(enem$UF_PROVA)
length(table(enem$UF_PROVA))
# Observe que o n�mero de registros �nicos dessa coluna � 28, por�m, o Brasil
# possui 27 estados. Verificando mais atentamente, notamos que h� 1480 registros
# em branco nessa coluna (provavelmente, erro na hora da inser��o).
# N�o iremos tratar isso, para n�o perder 1480 registros que podem ser importantes
# para as outras colunas.

# Normalizando a coluna situacao_conclusao
table(enem$SITUACAO_CONCLUSAO)
# Segundo o dicion�rio de vari�veis:
# 1 -> J� conclui o Ensino M�dio
# 2 -> Estou cursando e concluirei o Ensino M�dio em 2011
# 3 -> Estou cursando e concluirei o Ensino M�dio ap�s 2011
# 4 -> N�o conclui e n�o estou cursando o Ensino M�dio
enem$SITUACAO_CONCLUSAO <- gsub('1', 'CONCLU�DO', enem$SITUACAO_CONCLUSAO)
enem$SITUACAO_CONCLUSAO <- gsub('2', 'CONCLUIR� NO ANO', enem$SITUACAO_CONCLUSAO)
enem$SITUACAO_CONCLUSAO <- gsub('3', 'CONCLUIR� AP�S ANO', enem$SITUACAO_CONCLUSAO)
enem$SITUACAO_CONCLUSAO <- gsub('4', 'N�O CONCLU�DO/CURSANDO', enem$SITUACAO_CONCLUSAO)
table(enem$SITUACAO_CONCLUSAO)

# Quando foi feito str(enem), verificamos que as colunas de notas s�o do tipo
# char e n�o do tipo num�rica
# Observe dessa forma:
summary(enem$NOTA_CIENCIAS_HUMANAS)
summary(enem$NOTA_CIENCIAS_NATUREZA)
summary(enem$NOTA_LINGUAGENS_CODIGOS)
summary(enem$NOTA_MATEMATICA)
summary(enem$NOTA_REDACAO)

# Convertendo essas colunas para o tipo num�rico (lembrando que iremos ficar
# com linhas com valores NA's, dado que nem todos os valores das linhas podem
# ser convertidos para n�mero)
enem$NOTA_CIENCIAS_HUMANAS <- as.numeric(enem$NOTA_CIENCIAS_HUMANAS)
enem$NOTA_CIENCIAS_NATUREZA <- as.numeric(enem$NOTA_CIENCIAS_NATUREZA)
enem$NOTA_LINGUAGENS_CODIGOS <- as.numeric(enem$NOTA_LINGUAGENS_CODIGOS)
enem$NOTA_MATEMATICA <- as.numeric(enem$NOTA_MATEMATICA)
enem$NOTA_REDACAO <- as.numeric(enem$NOTA_REDACAO)
# Verificando que s�o, de fato, do tipo num�rico
str(enem)


# Realizando algumas an�lises gr�ficas
ggplot(data = enem) + geom_bar(aes(x = TIPO_LINGUA), stat = 'count')

# Gr�fico de barras com sexo e o tipo de idioma escolhido
# Primeiramente, fazendo uma filtragem para que n�o usemos valores '.' de tipo de 
# idioma
tp_lingua_sexo <- enem %>% 
                    filter(TIPO_LINGUA != '.') %>% 
                    select(all_of(c('SEXO', 'TIPO_LINGUA')))
plot_idioma_sexo <- ggplot(data = tp_lingua_sexo) +
                      geom_bar(aes(x = SEXO, fill = TIPO_LINGUA), 
                               stat = 'count', position = position_dodge())
p <- plot_idioma_sexo +
      ggtitle('Idioma escolhido por sexo') +
      xlab('Sexo') + ylab('Quantidade')
p <- p + theme_linedraw() +
      theme(plot.title = element_text(hjust = 0.5))

plot_idioma_sexo <- p
plot_idioma_sexo

#Gr�fico sobre a situa��o de escolaridade das pessoas que est�o fazendo o Enem por estado
options(scipen = 9999)

ggplot(data = enem) +
  geom_bar(aes(x = UF_PROVA), stat = 'count')

uf_prova <- enem %>% 
              filter(UF_PROVA != '') %>%
              select(all_of(c('UF_PROVA', 'SITUACAO_CONCLUSAO')))

plot_uf_conclusao <- ggplot(data = uf_prova) +
                     geom_bar(aes(x = UF_PROVA, fill = SITUACAO_CONCLUSAO),
                               position = position_dodge()) + 
                     facet_grid(SITUACAO_CONCLUSAO~.)
p <- plot_uf_conclusao + 
       ggtitle('Situa��o escolar por estado') +
       xlab('Estado') + ylab('Quantidade')

p <- p + theme_linedraw() +
      labs(fill = 'Situa��o') + 
      theme(plot.title = element_text(hjust = 0.5))
plot_uf_conclusao <- p
plot_uf_conclusao


# Visualizando a m�dia de idade por sexo e UF da prova
summary(enem$IDADE)
# Eliminando registros que s�o NA's na coluna IDADE
idade_uf <- enem %>%
               filter(!is.na(IDADE))
summary(idade_uf$IDADE)
# Agrupando os dados por UF_PROVA e SEXO e aplicando a m�dia de idade
media_idade_sexo_uf <- idade_uf %>% 
                        group_by(UF_PROVA, SEXO) %>%
                        summarise(media = mean(IDADE))
# Removendo registros onde UF_PROVA � vazio
media_idade_sexo_uf <- media_idade_sexo_uf %>%
                        filter(UF_PROVA != '')
# Gerando a visualiza��o (gr�fico de pir�mide)
ggplot(data = media_idade_sexo_uf) +
   geom_bar(aes(x = UF_PROVA, y = media, fill = SEXO),
            position = position_dodge(), stat = 'identity') +
   coord_flip() # Gr�fico de barras

plot_piram_idade <- ggplot(data = media_idade_sexo_uf, 
                      aes(x = reorder(UF_PROVA, -media),
                          y = ifelse(SEXO == 'MASCULINO', -media, media),
                          fill = SEXO)) + 
                  geom_bar(stat = 'identity') +
                  coord_flip()

plot_piram_idade <- plot_piram_idade + 
   scale_y_continuous(labels = abs) # Deixar os valores de y como positivo

plot_piram_idade <- plot_piram_idade +
                     ggtitle('M�dia de idade por sexo e UF da prova') +
                     ylab('M�dia da idade') +
                     xlab('Estado') +
                     theme_bw() +
                     theme(plot.title = element_text(hjust = 0.5))

plot_piram_idade <- plot_piram_idade + 
                     scale_fill_manual(values = c('hotpink', 'dodgerblue'))

plot_piram_idade <- plot_piram_idade +
                     geom_text(aes(label = round(media, digits = 2),
                                   hjust = 0.5),
                               size = 4.5,
                               colour = 'black', 
                               fontface = 'bold')
plot_piram_idade


# Gr�fico da m�dia de Ci�ncias Humanas e Matem�tica em rela��o a idade
# Ciencias Humanas
notas_ciencias_humanas <- enem %>% 
   filter(!is.na(NOTA_CIENCIAS_HUMANAS) & !is.na(IDADE) & IDADE > 17)
# Calculando a m�dia
nota_ciencias_humanas_idade <- notas_ciencias_humanas %>% 
                                 group_by(IDADE) %>%
                                 summarise(media_nota_ciencias_humanas = mean(NOTA_CIENCIAS_HUMANAS))

ggplot(data = nota_ciencias_humanas_idade) +
   geom_point(aes(x = IDADE, y = media_nota_ciencias_humanas))

# Matematica
notas_matematica <- enem %>%
   filter(!is.na(NOTA_MATEMATICA) & !is.na(IDADE) & IDADE > 17)
# Calculando a m�dia
nota_matematica_idade <- notas_matematica %>%
                           group_by(IDADE) %>%
                           summarise(media_nota_matematica = mean(NOTA_MATEMATICA))

ggplot(data = nota_matematica_idade) +
   geom_point(aes(x = IDADE, y = media_nota_matematica))

# Gerando um gr�fico de pontos com as duas disciplinas
# Fazendo um merge dos dois dfs construidos
notas_ch_mat_idade <- merge(nota_ciencias_humanas_idade,
                            nota_matematica_idade,
                            all = T)
View(notas_ch_mat_idade)
# Convertendo as duas colunas de notas do df em linha
notas_ch_mat_idade <- melt(notas_ch_mat_idade,
                           id.vars = 'IDADE')
View(notas_ch_mat_idade)

# Gerando o gr�fico
plot_scatter_ch_mat <- ggplot(data = notas_ch_mat_idade) +
                        geom_point(aes(IDADE, value, color = variable))
p <- plot_scatter_ch_mat +
      ggtitle('M�dia das notas por idade e �rea') + 
      xlab('Idade') +
      ylab('M�dia (Notas)')
p <- p + theme_bw() +
      scale_color_manual(name = '�rea', 
                         values = c('blue','red'),
                         labels = c('Ci�ncias\nHumanas', 'Matem�tica'))
plot_scatter_ch_mat <- p
plot_scatter_ch_mat                  


# Gr�fico de linhas das m�dias das notas ao longo do tempo

media_anos <- enem %>% filter(!is.na(NOTA_CIENCIAS_HUMANAS) &
                              !is.na(NOTA_CIENCIAS_NATUREZA) &
                              !is.na(NOTA_LINGUAGENS_CODIGOS) &
                              !is.na(NOTA_MATEMATICA) &
                              !is.na(NOTA_REDACAO)) %>%
                       group_by(ANO) %>%
                       summarise(media_ch = mean(NOTA_CIENCIAS_HUMANAS),
                                 media_cn = mean(NOTA_CIENCIAS_NATUREZA),
                                 media_lc = mean(NOTA_LINGUAGENS_CODIGOS),
                                 media_mt = mean(NOTA_MATEMATICA),
                                 media_rd = mean(NOTA_REDACAO))
View(media_anos)

# Gerando o gr�fico
media_anos <- as.data.frame(media_anos)
media_anos_2 <- melt(media_anos, id.vars = 'ANO')

plot_line_notas <- ggplot(data = media_anos_2) +
                     geom_line(aes(x = ANO, y = value, color = variable))

p <- plot_line_notas +
      ggtitle('M�dia das notas por �rea e Ano') +
      xlab('Ano') +
      ylab('M�dia')+
      geom_point(aes(ANO, value, color = variable), size = 3)

p <- p + geom_text(aes(x = ANO, y = value, color = variable, 
                       label = round(value, digits = 2),
                       hjust = -0.15, vjust = 0.2))

p <- p + scale_color_discrete(name = '�reas', labels = c('Ci�ncias Natureza',
                                                    'Ci�ncias Humanas',
                                                    'Linguagens',
                                                    'Matem�tica',
                                                    'Reda��o')) +
         theme_bw()

plot_line_notas <- p
plot_line_notas


# Fazendo uma compara��o e verificando se h� alguma rela��o entre as m�dias de
# ci�ncias humanas, matem�tica e reda��o, identificando se h� alguma defici�ncia
# ou sucesso nas regi�es
# Filtrando por alguns estados, por idade, n�o considerando NA's nas �reas que queremos

enem_filtrado <- enem %>% 
                  filter(!is.na(NOTA_CIENCIAS_HUMANAS) & 
                         !is.na(NOTA_MATEMATICA) &
                         !is.na(NOTA_REDACAO) &
                         !is.na(IDADE) & IDADE > 17 &
                         UF_PROVA %in% c('CE', 'DF', 'MG', 'RS')) %>%
                  group_by(IDADE, UF_PROVA) %>%
                  summarise(media_nota_matematica = mean(NOTA_MATEMATICA),
                            media_nota_ciencias_humanas = mean(NOTA_CIENCIAS_HUMANAS),
                            media_nota_redacao = mean(NOTA_REDACAO))

View(enem_filtrado)

# Gerando o gr�fico
plot_bolhas_uf_notas <- ggplot(data = enem_filtrado) + 
                           geom_point(aes(x = media_nota_ciencias_humanas,
                                          y = media_nota_matematica,
                                          color = UF_PROVA,
                                          size = media_nota_redacao),
                                      alpha = 0.5)


p <- plot_bolhas_uf_notas +
      ggtitle('M�dias Matem�tica, Ci�ncias Humanas e Reda��o por estado') +
      xlab('M�dia Ci�ncias Humanas') +
      ylab('M�dia Matem�tica')

p <- p + labs(color='UF Prova', size = 'M�dia Reda��o')

p <- p +
      theme_bw() +
      theme(legend.position = 'left')

plot_bolhas_uf_notas <- p
plot_bolhas_uf_notas



# Gerando um gr�fico de boxplot da nota de reda��o, para todos os estados
# Filtrando a base de dados

notas_redacao_uf <- enem %>% 
                     filter(UF_PROVA != '' &
                            !is.na(NOTA_REDACAO)) %>%
                     select(all_of(c('UF_PROVA', 'NOTA_REDACAO')))

View(notas_redacao_uf)

# Gerando o gr�fico
plot_box_uf_redacao <- ggplot(data = notas_redacao_uf) +
                        geom_boxplot(aes(x = UF_PROVA, y = NOTA_REDACAO))
dados_boxplot <- plot_box_uf_redacao$data
View(dados_boxplot)

# Criando uma coluna que indica se aquela nota � de um dos estados que filtramos 
# em um gr�fico anterior
dados_boxplot <- dados_boxplot %>%
                  mutate(estado_filtro = if_else(UF_PROVA %in% c('CE', 'DF', 'MG', 'RS'), T, F))
View(dados_boxplot)

# Gerando o gr�fico de tal forma que os boxplots desses estados estejam destacados
p <- ggplot(data = dados_boxplot) +
      geom_boxplot(aes(x = UF_PROVA, y = NOTA_REDACAO, fill = estado_filtro),
                   outlier.colour = 'red', outlier.size = 3.5)
p <- p +
      xlab('UF Prova') +
      ylab('Nota Reda��o') +
      theme_bw()
p <- p + scale_fill_manual(name = '', values = c('chocolate3', 'chartreuse3'),
                           labels = c('N�o estado filtrado', 'Estado filtrado'))
plot_box_uf_redacao <- p
plot_box_uf_redacao


# Qual a rela��o das m�dias estaduais com a m�dia nacional, para a �rea de reda��o?

media_redacao <- enem %>% 
                  filter(UF_PROVA != '' & !is.na(NOTA_REDACAO)) %>%
                  mutate(media_nacional = mean(NOTA_REDACAO)) %>%
                  group_by(UF_PROVA, media_nacional) %>%
                  summarise(media_uf = mean(NOTA_REDACAO))

plot_bar_error <- ggplot(data = media_redacao, aes(x = reorder(UF_PROVA, media_uf),
                                                   y = media_uf)) +
                  geom_errorbar(aes(ymin = 0, ymax = media_nacional), size = 1) + # representa a media nacional
                  geom_bar(stat = 'identity') +
                  coord_flip() 

# Destacando os estados que destacamos nos gr�ficos anteriores
dados_bar_error <- plot_bar_error$data

dados_bar_error <- dados_bar_error %>%
                     mutate(estado_filtro = if_else(UF_PROVA %in% c('CE', 'DF', 'MG', 'RS'), T, F))
   
p <- ggplot(data = dados_bar_error, aes(x = reorder(UF_PROVA, media_uf),
                                      y = media_uf)) +
      geom_errorbar(aes(ymin = 0, ymax = media_nacional), size = 1) + # representa a media nacional
      geom_bar(aes(fill = estado_filtro), stat = 'identity') +
      coord_flip() +
      guides(fill = FALSE) +
      ggtitle('M�dia nota reda��o por UF/Nacional') +
      xlab('UF Prova') +
      ylab('M�dia Reda��o') +
      theme_bw()
p
# Dos estados destacados, apenas o estado de MG possui uma m�dia de reda��o maior
# que a m�dia nacional
plot_bar_error <- p
plot_bar_error


# Criando uma ou mais p�ginas com todos os gr�ficos gerados
library(gridExtra)
library(grid)

# Como h� muitos gr�ficos que precisam de espa�o para serem bem interpretados,
# a solu��o � fazer mais de uma p�gina

# Primeira p�gina com 3 gr�ficos
lay1 <- rbind(c(1,1),
             c(2,3))

grid.arrange(plot_line_notas,
             plot_box_uf_redacao,
             plot_bar_error, layout_matrix = lay1)

# Segunda p�gina com 3 gr�ficos
lay2 <- rbind(c(1,2),
              c(3,3))
grid.arrange(plot_idioma_sexo,
             plot_scatter_ch_mat,
             plot_bolhas_uf_notas, layout_matrix = lay2)

# Terceira p�gina com 2 gr�ficos
lay3 <- rbind(c(1,1),
              c(2,2))
grid.arrange(plot_piram_idade,
             plot_uf_conclusao, layout_matrix = lay3)
