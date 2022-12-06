module LoginSupport
  def sign_in(user)
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  def drop_files files, drop_area_class
    js_script = "fileList = Array();"
    # files.count.times do |i|
      # Generate a fake input selector
      # page.execute_script("if ($('#seleniumUpload#{i}').length == 0) { seleniumUpload#{i} = window.$('<input/>').attr({id: 'seleniumUpload#{i}', type:'file'}).appendTo('body'); }")
      page.execute_script("if ($('#seleniumUpload').length == 0) { seleniumUpload = window.$('<input/>').attr({id: 'seleniumUpload', type:'file'}).appendTo('body'); }")
      # Attach file to the fake input selector through Capybara
      # attach_file("seleniumUpload#{i}", files[i])
      attach_file("seleniumUpload", files)
      # Build up the fake js event
      js_script = "#{js_script} fileList.push(seleniumUpload.get(0).files[0]);"
    end

    # Trigger the fake drop event
    page.execute_script("#{js_script} e = $.Event('drop'); e.originalEvent = {dataTransfer : { files : fileList } }; $('.#{drop_area_class}').trigger(e);")
  end  
end
