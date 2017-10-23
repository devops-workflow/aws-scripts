#
# List the tag for each image that only has a number tag
#
# To run:
# jq -r -f number-only.jq image-list.json | awk NF

.imageDetails[] |
if (.imageTags | length == 1) and
 (.imageTags[] | test("^[0-9]+$"))
 then
  .imageTags[0]
else
  ""
end
