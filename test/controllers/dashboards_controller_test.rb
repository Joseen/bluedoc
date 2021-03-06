# frozen_string_literal: true

require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /" do
    assert_require_user do
      get "/"
    end

    doc0 = create(:doc)
    doc1 = create(:doc)
    group = create(:group)
    group.add_member(@user, :editor)
    UserActive.track(doc0, user: @user)
    UserActive.track(doc1, user: @user)
    UserActive.track(doc0.repository, user: @user)

    sign_in @user
    get "/"
    assert_equal 200, response.status
    assert_select ".recent-docs .recent-doc-item", 2
    assert_select ".group-list .group-item", 1
    # assert_select ".group-list .group-item.group-item-more", 1
    assert_select ".repo-list .repo-item", 1
    # assert_select ".repo-list .repo-item.repo-item-more", 1

    get "/dashboard"
    assert_redirected_to "/"
  end

  test "GET /dashboard/docs" do
    assert_require_user do
      get "/dashboard/docs"
    end

    doc0 = create(:doc)
    doc1 = create(:doc)
    UserActive.track(doc0, user: @user)
    UserActive.track(doc1, user: @user)

    sign_in @user
    get "/dashboard/docs"
    assert_equal 200, response.status
    assert_select ".recent-docs .recent-doc-item", 2
  end

  test "GET /dashboard/repositories" do
    assert_require_user do
      get "/dashboard/repositories"
    end

    group = create(:group)
    group.add_member(@user, :editor)
    repo0 = create(:repository, user: group)
    repo1 = create(:repository, user: group)
    UserActive.track(repo0, user: @user)
    UserActive.track(repo1, user: @user)

    sign_in @user
    get "/dashboard/repositories"
    assert_equal 200, response.status
    assert_select ".dashboard-repos .recent-repo-item", 2
  end

  test "GET /dashboard/groups" do
    assert_require_user do
      get "/dashboard/groups"
    end

    group0 = create(:group)
    group0.add_member(@user, :editor)
    group1 = create(:group)
    group1.add_member(@user, :reader)
    UserActive.track(group0, user: @user)
    UserActive.track(group1, user: @user)

    sign_in @user
    get "/dashboard/groups"
    assert_equal 200, response.status
    assert_select ".dashboard-groups .recent-group-item", 2
  end

  test "GET /dashboard/stars" do
    assert_require_user do
      get "/dashboard/stars"
    end

    repo0 = create(:repository)
    repo1 = create(:repository)

    @user.star_repository(repo0)
    @user.star_repository(repo1)

    sign_in @user
    get "/dashboard/stars"
    assert_equal 200, response.status
    assert_select ".dashboard-repos .recent-repo-item", 2
    assert_select ".menu-item.selected", text: "Repositories"
  end

  test "GET /dashboard/stars/docs" do
    assert_require_user do
      get "/dashboard/stars/docs"
    end

    doc0 = create(:doc)
    doc1 = create(:doc)

    @user.star_doc(doc0)
    @user.star_doc(doc1)

    sign_in @user
    get "/dashboard/stars/docs"
    assert_equal 200, response.status
    assert_select ".recent-docs .recent-doc-item", 2
    assert_select ".menu-item.selected", text: "Docs"
  end

  test "GET /dashboard/stars/notes" do
    assert_require_user do
      get "/dashboard/stars/notes"
    end

    note0 = create(:note)
    note1 = create(:note)

    @user.star_note(note0)
    @user.star_note(note1)

    sign_in @user
    get "/dashboard/stars/notes"
    assert_equal 200, response.status
    assert_select ".recent-notes .recent-doc-item", 2
    assert_select ".menu-item.selected", text: "Notes"
  end

  test "GET /dashboard/watches" do
    assert_require_user do
      get "/dashboard/watches"
    end

    repo0 = create(:repository)
    repo1 = create(:repository)

    @user.watch_repository(repo0)
    @user.watch_repository(repo1)

    sign_in @user
    get "/dashboard/watches"
    assert_equal 200, response.status
    assert_select ".dashboard-repos .recent-repo-item", 2
  end
end
