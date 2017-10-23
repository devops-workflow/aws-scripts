#
# List the tag for each image that only has a date tag
#
# To run:
# jq -r -f date-only.jq image-list.json | awk NF

.imageDetails[] |
if (.imageTags | length == 1) and
 (.imageTags[] | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}_"))
 then
  .imageTags[0]
else
  ""
end
