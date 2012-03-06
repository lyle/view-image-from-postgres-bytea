This is a sinatra app that pulls some content from postgres.
Notably it uses "PGconn.unescape_bytea" to compensate for Postgres's 
greedy *escape_bytea* which causes no end of pain.


! send_data is depricated

At first this is what I thought was the problem, but it was actually postgres driver in datamapper. 
So if you run into a problem of not being able to pull an image out of a postgres bytea then maybe this will help.


! Testing if you got image

If you have a byte aray in postgres holding your image data, here is how you can pull it out the hard way:
Log into psql and do this:
<pre><code>
	\copy (select encode(data, 'hex') from images where id=5) TO '/Users/yourname/Desktop/image.hex';	
</code></pre>

That should make a hex version of the file. Then in terminal simply run:
<pre><code>
	xxd -p -r image.hex > image.jpg
</code></pre>