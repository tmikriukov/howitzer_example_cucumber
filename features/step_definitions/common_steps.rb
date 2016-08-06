# frozen_string_literal: true
#############################################################
#                      PREREQUISITES                        #
#############################################################

Given /^opened browser$/ do
  Howitzer::Web::BlankPage.instance
end

Given /^(.+) page of web application$/, &:open

Given /^there is registered user$/ do
  @user = create(:user)
end

Given /^there is registered user1$/ do
  @user1 = create(:user)
end

Given /^there is registered user2$/ do
  @user2 = create(:user)
end

Given /^I am logged in as user1$/ do
  user1 = @user1
  LoginPage.open
  LoginPage.on { login_as(user1.email, user1.password) }
end

Given /^article with parameters$/ do |table|
  article = table.rows_hash.symbolize_keys
  ArticleListPage.on { add_new_article }
  NewArticlePage.on do
    fill_form(table.rows_hash.symbolize_keys)
    submit_form
  end
end

Given /^I am logged in as admin user$/ do
  LoginPage.open
  LoginPage.on { login_as(settings.def_test_user, settings.def_test_pass) }
end

Given /^I am logged in as user$/ do
  user = @user
  LoginPage.open
  LoginPage.on { login_as(user.email, user.password) }
end

Given /^I am on (.+) page$/, &:open

Given /^user logged out$/ do
  ArticlePage.on { main_menu_section.choose_menu('Logout') }
end

####################################
#              ACTIONS             #
####################################

# we hanlde blank page separately
When /^I open (?!blank)(.+?) page$/, &:open

When /^I click (.+?) menu item on (.+) page$/ do |text, page|
  page.as_page_class.on { main_menu_section.choose_menu(text.capitalize) }
end

When /^I fill form on login page$/ do
  user = @user
  LoginPage.on { fill_form(email: user.email, password: user.password) }
end

When /^I fill form on login page with remembering credentials$/ do
  user = @user
  LoginPage.on { fill_form(email: user.email, password: user.password, remember_me: 'yes') }
end

When /^I submit form on (.+) page$/ do |page|
  page.as_page_class.on { submit_form }
end

When /^I confirm (.+) account from (.+) email$/ do |recipient, email|
  email.as_email_class.find_by_recipient(recipient).confirm_my_account
end

When /^I click back to articles link on (.+) page$/ do |page|
  page.as_page_class.on { back_to_article_list }
end

When /^I click Forgot password\? link on login page$/ do
  LoginPage.on { navigate_to_forgot_password_page }
end

When /^I click on (.+) link on users page$/ do |email|
  UsersPage.on { open_user(email) }
end

When /^I log out$/ do
  HomePage.on { main_menu_section.choose_menu('Logout') }
end

When /^I navigate to (.*) list via main menu$/ do |item|
  HomePage.on { main_menu_section.choose_menu(item.capitalize) }
end

####################################
#              CHECKS              #
####################################

# we hanlde blank page separately
Then /^(?!blank)(.+) page should be displayed$/ do |page|
  expect(page).to be_displayed
end

Then /^I should be logged in the system$/ do
  expect(HomePage).to be_authenticated
end

Then /^I should not be logged in the system$/ do
  expect(HomePage).to be_not_authenticated
end

Then /^I should see following text on (.+) page:$/ do |page, text|
  page.as_page_class.on { expect(text).to include(text) }
end

Then /^I should see user email on (.+) page$/ do |page|
  page.as_page_class.on { expect(text).to include(@user.email) }
end

Then /^I should receive (.+) email for (.+) recipient$/ do |email, recipient|
  email.as_email_class.find_by_recipient(recipient)
end

Then /^I should be redirected to (.+) page$/, &:given
