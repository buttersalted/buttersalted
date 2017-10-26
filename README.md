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

`Group` is used to create and maintain groups or classifications of
`food`. This can be used as a method of filtering and aggregating
`food`. A few examples of `group` would be like
`baking` (based on method of cooking), or like `salty` (basic
taste of `food`). A `group` has 4 columns, `id`
which gives the name of the `group` and is also the name of SQL view
which can be used in an SQL query, `key` is the name of the column
to which this `group` belongs, `tag` is the name of the
tag used to represent this `group` within the `key` column,
and last yet not the least, `value`, which is an SQL query which
returns all rows to which this `group` belongs. Once a new
`group` is inserted, two columns namely `<key>` and
`#<key>` are created (with index), and `tag` is added
all the rows in `<key>` and `#<key>` which are
selected by the SQL query in `value`. If any new rows are added
`food`, they can be refreshed later. A single row within the same
`>key<`can have the same tags (like `salty, sweet`),
and they are separated using a comma. Deleting a group deletes the associated
view, and the tags from all `food`.

## Term

`Term` describes alternative terms for columns in `food`.
Each column in `food` is case-sensitive, descriptive and long. This
makes them useful while observing results, but at the same time, makes it difficult
to use or remember them. Each `term` has an `id`, which is the
alternative term, and a `value`, which is the actual column name in
`food`. Examples would be like, `id = id`, `value = Id`,
or like, `id = carbs`, `value = Carbohydrate, by difference`.
These alternative terms can be used in an `query`, or in `food`
search. Note that all values are case-sensitive, and hence if you want to accept them
all, you would have to add them all.

## Type

`Type` is the definition of every column in `food`. Any change
made here alters the table, and may also result in loss of data. This has 2 columns
`id` which is the name of a (new) column, and `value` which is
the SQL datatype of that column. An example would be like `id = Vitamin A`,
and `value = REAL`. Once a `type` is added, a column is created
in `food`, along with an index. Deleting a `type` deletes the
column, and the associated index.

## Unit

`Unit` is used to remember unit conversion factors (to base unit).
These values are put to use when adding a new `food`, where a
quantity is written as `<magnitude> <unit>`, or even
`<magnitude><unit>`. There are 2 columns, `id`
is the name of the unit, and `value` is its conversion factor to base
unit. Base unit is `Cal` for `Energy`, `IU` for
`Vitamin A`, `Vitamin C` and `Vitamin D`, and
`g` for the rest. Examples would be like `id = kg`,
`value = 0.001` or `id = tsp`, `value = 4`.
Please note that the `id` is case-sensitive, and so if you want to
recognize `KG` as kilogram, it must also be added like so `id = KG`,
`value = 0.001`. Scientific notation is supported for the `value`
field like `1e-3`. For special base units like `IU`, it is possible
to mention a different conversion factor for each column by using the name of the column
as `id`, and the column specific conversion factor as `value`.
An example would be `id = Vitamin A`, `value = 1.66e+6` (assuming
beta-carotene). Now, if `Vitamin A` is written in `mcg` then it
will first be converted to `g`, and finally to `IU`. Thanks
for making it this far.
