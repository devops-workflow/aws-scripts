#
# List all tags that are the only tag for the image
#
# To run:
# jq -r -f number-single-only.jq image-list.json | awk NF

# Fix to only match numbers

.imageDetails[] |
if (.imageTags | length == 1) and (.imageTags[0] | test("^[0-9]+$")) then
  .imageTags[0]
else
  ""
end
