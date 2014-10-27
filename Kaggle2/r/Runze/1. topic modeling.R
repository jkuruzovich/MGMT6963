library(rjson)
library(plyr)
library(NLP)
options(java.parameters = "-Xmx4g")
library(openNLP)
library(tm)
library(topicmodels)
library(slam)
library(caret)
library(wordcloud)
library(skmeans)
options(stringsAsFactors = F)

train = fromJSON(file = 'train.json')
train = lapply(train, lapply, function(x) ifelse(is.null(x), NA, x))
train = lapply(train, lapply, lapply, function(x) ifelse(is.null(x), NA, x))
train_df = data.frame(matrix(unlist(train), byrow = T, nrow = length(train)))
names(train_df) = names(train[[1]])
save(train_df, file = 'train.RData')

load(file = 'train.RData')
#clean the request fields (incl. request title)
req = paste(train_df$request_title, train_df$request_text_edit_aware)
req = tolower(req)
req = gsub('[^[:alpha:]]', ' ', req)

rm_space = function(x) {
  x = gsub('^ +', '', x)
  x = gsub(' +$', '', x)
  x = gsub(' +', ' ', x)  
}

req = rm_space(req)
train_df$req = req
save(train_df, file = 'train.RData')

#create corpus and remove stopwords
c = Corpus(VectorSource(req))
c_clean = tm_map(c, removeWords, c(stopwords('SMART'), 'pizza', 'pizzas', 'request', 'requests'))
c_clean = tm_map(c_clean, rm_space)

#function to keep only nouns (per the paper)
pos_tag = function(x) {
  gc() #clean garbage to free up memory space (otherwise an error may be thrown out reporting memory shortage)
  sent_token_annotator = Maxent_Sent_Token_Annotator()
  word_token_annotator = Maxent_Word_Token_Annotator()
  a = annotate(x, list(sent_token_annotator, word_token_annotator))
  
  pos_tag_annotator = Maxent_POS_Tag_Annotator()
  a = annotate(x, pos_tag_annotator, a)
  w = subset(a, type == 'word')
  return(unlist(w$features))
}

c_t = lapply(c_clean, pos_tag) #took a long, long time to run
save(c_t, file = 'pos_tag.RData')

#break corpus strings into words in order to identify nouns
c_w = lapply(c_clean, function(x) unlist(strsplit(x, ' +')))

#check word count
c_t_len = unlist(lapply(c_t, length))
c_w_len = unlist(lapply(c_w, length))
diff = c_t_len - c_w_len #table(diff) shows all 0 - we are good

#keep only nouns
c_w_noun = list()
for (i in 1:length(c_w)) {
  c_w_noun[[i]] = c_w[[i]][grep('NN', c_t[[i]])]
}

#paste back to corpus
c_s = lapply(c_w_noun, paste, collapse = ' ')
c_s = Corpus(VectorSource(c_s))
save(c_s, file = 'corpus.RData')

#construct document-term matrix using the request field
dtm = DocumentTermMatrix(c_s)
save(dtm, file = 'dtm.RData')

#trim dtm based on tf-idf
#calculate tf as the average of the % term frequency within each document
tf = tapply(dtm$v / row_sums(dtm)[dtm$i], dtm$j, mean)
#calculate idf as log2(the total number of documents / each term's frequency across all documents)
idf = log2(nDocs(dtm) / col_sums(dtm > 0))

tf_idf = tf * idf

#only keep terms that have a tf-idf >= the 25th percentile
dtm_trim = dtm[, tf_idf >= quantile(tf_idf, .25)]
trim_ind = which(row_sums(dtm_trim) > 0)
dtm_trim = dtm_trim[trim_ind, ]
save(dtm_trim, file = 'dtm_trim.RData')

train_trim = train_df[trim_ind, ]
save(train_trim, file = 'train_trim.RData')

#lda
#determine the optimal number of topics via cv
set.seed(2014)
f = createFolds(train_trim$requester_received_pizza)
lda_eval = data.frame(fold = integer(), topic = integer(), perplex = numeric())

for (i in 1:length(f)) {
  for (k in 2:10) {
    cat(i, k, '\n')
    dtm_train = dtm_trim[-f[[i]], ]
    dtm_test = dtm_trim[f[[i]], ]
    
    lda_train = LDA(dtm_train, k, control = list(seed = 2014))
    lda_test = LDA(dtm_test, model = lda_train)
    
    lda_eval = rbind(lda_eval, c(i, k, perplexity(lda_test)))
  }
}
names(lda_eval) = c('fold', 'topic', 'perplex')
pp = ggplot(lda_eval, aes(x = topic, y = perplex, colour = as.factor(fold), group = as.factor(fold))) + geom_line()
ggsave(pp, file = 'perplex.jpg')

sink('lda.txt')
ddply(lda_eval, .(fold), summarize, min_p = min(perplex), min_t = topic[which.min(perplex)])
sink()
#10 appears to be the best split

lda_m = LDA(dtm_trim, 10, control = list(seed = 2014))
lda_topics = posterior(lda_m)$topics
lda_terms = posterior(lda_m)$terms

#word cloud
words = names(lda_terms[1, ])
for (i in 1:10) {
  png(paste0('lda', i, '.png'), width = 400, height = 400)
  wordcloud(words, lda_terms[i, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
  dev.off()
}

#try sk-means
set.seed(2014)
sk_m = skmeans(dtm_trim, 5)
sk_pt = sk_m$prototypes

#word cloud
words = names(sk_pt[1, ])
wordcloud(words, sk_pt[1, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
wordcloud(words, sk_pt[2, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
wordcloud(words, sk_pt[3, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
wordcloud(words, sk_pt[4, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
wordcloud(words, sk_pt[5, ], max.words = 200, random.order = F, col = brewer.pal(8, "Dark2"))
