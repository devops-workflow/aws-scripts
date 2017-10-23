#
# List the number tag for each image that only has a number and date tag
#
# To run:
# jq -r -f number-and-date-only.jq image-list.json | awk NF

.imageDetails[] |
if (.imageTags | length == 2) and
 (.imageTags[] | test("^[0-9]+$")) and
 (.imageTags[] | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}_"))
 then
  .imageTags[] | capture("^(?<num>[0-9]+)$").num
else
  ""
end
