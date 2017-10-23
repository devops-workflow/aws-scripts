#
# List a tag for each image that only has a date tag, a number tag, or a date and number tag
#
# To run:
# jq -r -f date-number-tags.jq image-list.json | awk NF

.imageDetails[] |
if (.imageTags | length == 1) then
  if (.imageTags[] | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}_")) or
     (.imageTags[] | test("^[0-9]+$"))
  then
    .imageTags[0]
  else
    ""
  end
elif (.imageTags | length == 2) and
 (.imageTags[] | test("^[0-9]+$")) and
 (.imageTags[] | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}_"))
 then
  .imageTags[] | capture("^(?<num>[0-9]+)$").num
else
  ""
end
