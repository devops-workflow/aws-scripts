#
# List all tags that are the only tag for the image
#
# To run:
# jq -r -f number-single-only.jq image-list.json | awk NF

.imageDetails[] |
if ( .imageTags | length == 1) then
  .imageTags[0]
else
  ""
end
