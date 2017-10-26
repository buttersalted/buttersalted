# foodsql

A new way to understand food through queries.


## Pipe

Pipe is a way to obtain food data from various reputed sources.

## Food

Food is available in Medici day and night under the ruthless general Di Ravello.
But every weird truth comes, with a bad buy one get one free truth. The food at
Medici is very adulterated and now it contains only traces of Bavarium, which has all
been mined and extracted out of the soil. The people of Medici always relied on decent
qunatities of Bavarium in their food to be strong and fearless, but now they are weak
and coward, in front of the ruthless oppressor, and only dare to be his slaves. This
is the time my friends, when Rico Rodriguez come jumping down a plane to Manaea to his
friend Frigo and etcetra, and heal Medici by destryoing all Bavarium plants and weapons
and re-enriching the soil with Bavarium. Viva Medici.

## Group

<code>Group</code> is used to create and maintain groups or classifications of
<code>food</code>. This can be used as a method of filtering and aggregating
<code>food</code>. A few examples of <code>group</code> would be like
<code>baking</code> (based on method of cooking), or like <code>salty</code> (basic
taste of <code>food</code>). A <code>group</code> has 4 columns, <code>id</code>
which gives the name of the <code>group</code> and is also the name of SQL view
which can be used in an SQL query, <code>key</code> is the name of the column
to which this <code>group</code> belongs, <code>tag</code> is the name of the
tag used to represent this <code>group</code> within the <code>key</code> column,
and last yet not the least, <code>value</code>, which is an SQL query which
returns all rows to which this <code>group</code> belongs. Once a new
<code>group</code> is inserted, two columns namely <code>&lt;key&gt;</code> and
<code>#&lt;key&gt;</code> are created (with index), and <code>tag</code> is added
all the rows in <code>&lt;key&gt;</code> and <code>#&lt;key&gt;</code> which are
selected by the SQL query in <code>value</code>. If any new rows are added
<code>food</code>, they can be refreshed later. A single row within the same
<code>&gt;key&lt;</code>can have the same tags (like <code>salty, sweet</code>),
and they are separated using a comma. Deleting a group deletes the associated
view, and the tags from all <code>food</code>.

## Term

<code>Term</code> describes alternative terms for columns in <code>food</code>.
Each column in <code>food</code> is case-sensitive, descriptive and long. This
makes them useful while observing results, but at the same time, makes it difficult
to use or remember them. Each <code>term</code> has an <code>id</code>, which is the
alternative term, and a <code>value</code>, which is the actual column name in
<code>food</code>. Examples would be like, <code>id = id</code>, <code>value = Id</code>,
or like, <code>id = carbs</code>, <code>value = Carbohydrate, by difference</code>.
These alternative terms can be used in an <code>query</code>, or in <code>food</code>
search. Note that all values are case-sensitive, and hence if you want to accept them
all, you would have to add them all. If you find anything here confusing, consider
messaging to <a href="mailto:wolfram77@gmail.com">wolfram77@gmail.com</a>.
