#
# List all tags for images that only have a number tag
#
# To run:
# jq -r -f number-single-only.jq image-list.json | awk NF

.imageDetails[] |
if (.imageTags | length == 1) and (.imageTags[] | test("^[0-9]+$")) then
  .imageTags[0]
else
  ""
end
