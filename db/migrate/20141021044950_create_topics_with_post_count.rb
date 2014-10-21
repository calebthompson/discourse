class CreateTopicsWithPostCount < ActiveRecord::Migration
  def change
    create_view :topics_with_post_count
  end
end
