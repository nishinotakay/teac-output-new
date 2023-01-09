module SystemSpecSupport
  def sign_in(user)
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  def drop_file file, drop_area_class_name
    # js_script = "fileList = Array();"
    page.execute_script("if ($('#seleniumUpload').length == 0) { seleniumUpload = window.$('<input/>').attr({id: 'seleniumUpload', type:'file'}).appendTo('body'); }")
    attach_file("seleniumUpload", file)
    # js_script = "#{js_script} fileList.push(seleniumUpload#{i}.get(0).files[0]);"
    js_script = "img = seleniumUpload.get(0).files[0];"
    page.execute_script("window.$('<h1>あいうえお</h1>').attr({class: 'prepend'}).prependTo('body');")
    page.save_screenshot('b.png')
    expect(page).to have_content('.prepend', with: 'hello')
    # page.execute_script("window.$('body').append('<h1>#{js_script}</h1>');")

    class_name = '.' + drop_area_class_name
    page.find(class_name).click
    page.execute_script("#{js_script} e = $.Event('drop'); e.originalEvent = {dataTransfer : { files : img } }; $('.#{drop_area_class_name}').trigger(e);")
    # page.execute_script <<-EOS
    #   img = seleniumUpload.get(0).files[0];
    #   console.log(img);
    #   e = $.Event('drop');
    #   e.originalEvent = {dataTransfer: { files : img } };
    #   $(".#{drop_area_class_name}").trigger(e);
    # EOS
  end
end
