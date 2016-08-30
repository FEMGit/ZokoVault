module FoldersHelper
  def path_helper(object)
    if (object.instance_of? Category)
      category_path(object)
    else
      # folder_path(object) # XXX I don't see a folder resources defclaration in
      # the routes file
      new_folder_path(object)
    end
  end
end
