This is a sinatra app that pulls some content from postgres.
Notably it uses "PGconn.unescape_bytea" to compensate for Postgres's 
greedy *escape_bytea* which causes no end of pain.


! send_data is depricated

At first this is what I thought was the problem, but it was actually postgres driver in datamapper. 
So if you run into a problem of not being able to pull an image out of a postgres bytea then maybe this will help.