# encoding: utf-8

require 'spec_helper'
require_dependency 'post_creator'

describe Category do
  describe '.update_stats' do
    before do
      @category = Fabricate(:category)
    end

    context 'with regular topics' do
      before do
        create_post(user: @category.user, category: @category.name)
        Category.update_stats
        @category.reload
      end

      it 'updates topic stats' do
        @category.topics_week.should == 1
        @category.topics_month.should == 1
        @category.topics_year.should == 1
        @category.topic_count.should == 1
        @category.post_count.should == 1
        @category.posts_year.should == 1
        @category.posts_month.should == 1
        @category.posts_week.should == 1
      end

    end

    context 'with deleted topics' do
      before do
        @category.topics << Fabricate(:deleted_topic,
                                      user: @category.user)
        Category.update_stats
        @category.reload
      end

      it 'does not count deleted topics' do
        @category.topics_week.should == 0
        @category.topic_count.should == 0
        @category.topics_month.should == 0
        @category.topics_year.should == 0
        @category.post_count.should == 0
        @category.posts_year.should == 0
        @category.posts_month.should == 0
        @category.posts_week.should == 0
      end
    end

    context 'with revised post' do
      before do
        post = create_post(user: @category.user, category: @category.name)

        SiteSetting.stubs(:ninja_edit_window).returns(1.minute.to_i)
        post.revise(post.user, 'updated body', revised_at: post.updated_at + 2.minutes)

        Category.update_stats
        @category.reload
      end

      it "doesn't count each version of a post" do
        @category.post_count.should == 1
        @category.posts_year.should == 1
        @category.posts_month.should == 1
        @category.posts_week.should == 1
      end
    end

    context 'for uncategorized category' do
      before do
        @uncategorized = Category.find(SiteSetting.uncategorized_category_id)
        create_post(user: Fabricate(:user), category: @uncategorized.name)
        Category.update_stats
        @uncategorized.reload
      end

      it 'updates topic stats' do
        @uncategorized.topics_week.should == 1
        @uncategorized.topics_month.should == 1
        @uncategorized.topics_year.should == 1
        @uncategorized.topic_count.should == 1
        @uncategorized.post_count.should == 1
        @uncategorized.posts_year.should == 1
        @uncategorized.posts_month.should == 1
        @uncategorized.posts_week.should == 1
      end
    end
  end
end
