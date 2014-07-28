# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
include Nanoc3::Helpers::LinkTo
# include Nanoc3::Filters::ColorizeSyntax

def item_titles
  @items.map { |i| i[:title] }
end

def item_identifiers
  @items.map { |i| i.identifier }
end

def item_filenames
  @items.map { |i| i.attributes[:filename] }
end

# Template for creating links based on item category.
def create_links(key)
  '<br>' + @items.select { |i| i[:category] == key }
  .map { |i| link_to(i[:title], i.identifier) }.join('<br>') + '<br>'*2
end

def create_research_links
  create_links("research")
end

def create_tutorial_links
  create_links("tutorial")
end

def create_other_links
  create_links("other")
end
