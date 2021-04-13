module CommentHelpers
  def add_comment(body)
    fill_in "active_admin_comment_body", with: body
    click_on "Add Comment"
  end
end

World(CommentHelpers)
