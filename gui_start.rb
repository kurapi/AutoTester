# encoding: UTF-8
require 'fox16'
require 'cgi'
require 'soap/wsdlDriver'
require 'watir'
require 'yaml'
require 'csv'
require 'rspec'
require 'win32/screenshot'
#require 'OCI8'
require 'logger'
require "open-uri"
require 'json'


$LOAD_PATH.unshift File.dirname(Dir.pwd)

include Fox
class FXFeatureDialog < FXDialogBox

  def initialize(owner,url,dir,treeList,list)
    # Invoke base class initialize function first
    super(owner, "TestCaseBox", DECOR_TITLE|DECOR_BORDER,0,0,800,600)

    # Bottom buttons
    descriptionBox = FXGroupBox.new(self, "Description", GROUPBOX_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE|LAYOUT_SIDE_BOTTOM)
    descriptionFrame = FXHorizontalFrame.new(descriptionBox, FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE|LAYOUT_SIDE_BOTTOM)
    @case_lists=[]
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_MULTIPLESELECT,   :width => 150))
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_MULTIPLESELECT,   :width => 250))
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_MULTIPLESELECT,   :width => 200))
    @case_lists[0].clearItems
    @case_lists[1].clearItems
    @case_lists[2].clearItems
    feature_arr = getFeatureList url
    feature_arr.each do |n|
      if n.match(/|/)!=nil
        featurehead,featurebody,featuredc=n.split('|')
        @case_lists[0].appendItem featurehead
        @case_lists[1].appendItem featurebody
        @case_lists[2].appendItem featuredc
      end
    end
    @case_lists[0].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[1].selectItem sender.anchorItem
      @case_lists[2].selectItem sender.anchorItem
    }
    @case_lists[1].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[0].selectItem sender.anchorItem
      @case_lists[2].selectItem sender.anchorItem
    }
    @case_lists[2].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[0].selectItem sender.anchorItem
      @case_lists[1].selectItem sender.anchorItem
    }
    infoMatrix = FXMatrix.new(descriptionFrame, 4, MATRIX_BY_COLUMNS|LAYOUT_MIN_HEIGHT)
    cancelButton = FXButton.new(infoMatrix,"Cancel", nil, self, ID_CANCEL)
    saveasButton = FXButton.new(infoMatrix,"AddItems")
    saveasButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[0].each do |n|
        list[0].appendItem n if n.selected?
      end
      @case_lists[1].each do |n|
        list[1].appendItem n if n.selected?
      end
      @case_lists[2].each do |n|
        list[2].appendItem n if n.selected?
      end
    }
  end
end

class FXEditDialog < FXDialogBox

  def initialize(owner,url,dir,treeList)
    # Invoke base class initialize function first
    super(owner, "TestCaseBox", DECOR_TITLE|DECOR_BORDER,500,500,600,600)

    # Bottom buttons
    descriptionBox = FXGroupBox.new(self, "Description", GROUPBOX_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE|LAYOUT_SIDE_BOTTOM)
    descriptionFrame = FXVerticalFrame.new(descriptionBox, FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE|LAYOUT_SIDE_BOTTOM)
    @description = FXDataTarget.new("")
    descriptionText=FXText.new(descriptionFrame, @description, FXDataTarget::ID_VALUE, TEXT_WORDWRAP|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    @description.value= IO.read(url).force_encoding("UTF-8")
    infoMatrix = FXMatrix.new(descriptionFrame, 4, MATRIX_BY_COLUMNS|LAYOUT_MIN_HEIGHT)

    cancelButton = FXButton.new(infoMatrix, "&Cancel", nil, self, ID_CANCEL)
    saveasButton = FXButton.new(infoMatrix,"Save As")
    saveasButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      time = Time.now.strftime "%Y-%m-%d_%H%M%S"
      File.open(File::dirname( dir.value)+"/#{time}.yml", (File::WRONLY | File::APPEND | File::CREAT))
      yamlText=File.new(File::dirname( dir.value)+"/#{time}.yml","r+")
      yamlText.syswrite descriptionText.text
      treeList.clearItems
      webItem = treeList.appendItem(nil, 'web')
      apiItem = treeList.appendItem(nil, 'api')
      iosItem = treeList.appendItem(nil, 'ios')
      androidItem = treeList.appendItem(nil, 'android')
      billItem = treeList.appendItem(nil, 'bill')

      @productTree = []
      traverse_dir_file(Dir.pwd+'\bill\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        billListItem = treeList.appendItem(billItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\web\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        webListItem = treeList.appendItem(webItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\api\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        apiListItem = treeList.appendItem(apiItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\ios\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        iosListItem = treeList.appendItem(iosItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\android\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        androidListItem = treeList.appendItem(androidItem, sectionName)
      end#
    }
  end
end

#get all fearurelist from url
def getFeatureList env_url
  allfearure_arr=Array.new
  Dir.foreach("#{env_url}") do |file|
    if file !="." and file !=".."
      testcase_hash = YAML.load(File.open("#{env_url}\\#{file}"))
      testcase_hash.each do |key,value|
        allfearure_arr=allfearure_arr|value
      end
    end
  end
  allfearure_arr
end

def creatCongif config_hash,configBox,type
  boxHash=Hash.new
  config_hash.each do |configKey,configValue|
    if configValue.class == Hash
    boxHash[configKey]=FXGroupBox.new(configBox, configValue['Description'], GROUPBOX_NORMAL|LAYOUT_FILL_X|FRAME_GROOVE|LAYOUT_CENTER_X)
      configValue.each do |labelKey,fieldValue|
        if fieldValue.class != Hash and labelKey  !=  'Description'
          boxHash[labelKey] = FXGroupBox.new(boxHash[configKey],'', GROUPBOX_NORMAL|LAYOUT_FILL_X|FRAME_GROOVE|LAYOUT_CENTER_X)
          boxHash[labelKey].backColor = FXRGB(248, 248, 255)
          boxHash[labelKey+configKey] = FXMatrix.new(boxHash[labelKey], 2, MATRIX_BY_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y,:padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0)
          boxHash[labelKey+fieldValue.to_s]=FXLabel.new(boxHash[labelKey+configKey],labelKey,:opts =>LAYOUT_FILL_X|LAYOUT_FILL_Y )
          field = FXDataTarget.new("")
          boxHash[fieldValue.to_s]=FXTextField.new(boxHash[labelKey+configKey], 60,field, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
          field.value = fieldValue.to_s
          field.connect(SEL_CHANGED){
            config_hash[configKey][labelKey]=field.value
            File.open("#{Dir.pwd}\\#{type}\\"+'config.yml',"wb"){|f| YAML.dump(config_hash, f)}
          }
          boxHash[fieldValue.to_s].shadowColor = FXRGB(248, 248, 255)
        end
      end
    creatCongif configValue,boxHash[configKey],type if configValue.class == Hash
    end
  end
end

def find_last_yaml(file_path)
  if File.directory? file_path
    Dir.foreach(file_path) do |file|
      if file !="." and file !=".."
        find_last_yaml(file_path+"/"+file)
      end
    end
  else
    @last_yaml=file_path if File.basename(file_path).match(/\.*yaml/)!=nil
  end
end

def traverse_dir_file(file_path)
  if File.directory? file_path
    Dir.foreach(file_path) do |file|
      if file !="." and file !=".."
        traverse_dir_file(file_path+"/"+file)
      end
    end
  else
    @productTree<<File.basename(file_path).to_s
  end
end

def traverse_dir(path)
  Dir.entries(path).each do |sub|
    if sub != '.' && sub != '..'
      if File.directory?("#{path}/#{sub}")
        @dir_array<<sub
      else
      end
    end
  end
end

def unicode_utf8(unicode_string)
  unicode_string.gsub(/\\u\w{4}/) do |s|
    str = s.sub(/\\u/, "").hex.to_s(2)
    if str.length < 8
      CGI.unescape(str.to_i(2).to_s(16).insert(0, "%"))
    else
      arr = str.reverse.scan(/\w{0,6}/).reverse.select{|a| a != ""}.map{|b| b.reverse}
      hex = lambda do |s|
        (arr.first == s ? "1" * arr.length + "0" * (8 - arr.length - s.length) + s : "10" + s).to_i(2).to_s(16).insert(0, "%")
      end
      CGI.unescape(arr.map(&hex).join)
    end
  end
end

def traverse_dir_base(path)
  Dir.entries(path).each do |sub|
    if sub != '.' && sub != '..'
      if File.directory?("#{path}/#{sub}")
        @array<</\d{4}-\d{2}-\d{2}_\d{6}/.match(sub.encode("UTF-8")).to_s if sub.match(/\d{4}-\d{2}-\d{2}_\d{6}/)!=nil
        traverse_dir_base("#{path}/#{sub}")
      else
      end
    end
  end
end

def traverse_dir_yaml(file_path)
  if File.directory? file_path
    Dir.foreach(file_path) do |file|
      if file !="." and file !=".."
        traverse_dir_yaml(file_path+"/"+file)
      end
    end
  else
    @array_yaml<<File.basename(file_path).encode("UTF-8") if File.basename(file_path).match(/\.*YAML/)!=nil
  end
end

###################################################################################################

class RAABrowserWindow < FXMainWindow

  def initialize(app)
    # Initialize base class
    super(app, "Ruby Application Archive", :opts => DECOR_ALL, :width => 1200, :height => 600)

    # Contents
    contents = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)

    # Horizontal splitter
    splitter = FXSplitter.new(contents, (LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y|SPLITTER_TRACKING|SPLITTER_HORIZONTAL),1)

    # Create a sunken frame to hold the tree list
    groupbox = FXGroupBox.new(splitter, "Contents",
                              LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE)
    frame = FXHorizontalFrame.new(groupbox,
                                  LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_SUNKEN|FRAME_THICK)

    # Create the empty tree list
    @treeList = FXTreeList.new(frame,
                               :opts => TREELIST_BROWSESELECT|TREELIST_SHOWS_LINES|TREELIST_SHOWS_BOXES|TREELIST_ROOT_BOXES|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    @treeList.connect(SEL_COMMAND) do |sender, sel, item|
      if @treeList.isItemLeaf(item)
        getApp().beginWaitCursor do
          begin
            @case_lists[0].clearItems
            @case_lists[1].clearItems
            @case_lists[2].clearItems
            @caseEnv="#{Dir.pwd}\\#{item.parent.to_s}\\testcases\\"
            @dir.value = "#{Dir.pwd}\\#{item.parent.to_s}\\testcases\\"+item.to_s
            @url= "#{Dir.pwd}\\#{item.parent.to_s}\\testcases\\"+item.to_s
            testcase_hash = YAML.load(File.open(@url))
            testcase_hash.each do |key,value|
              value.each do |m|
                if m.match(/|/)!=nil
                  featurehead,featurebody,featuredc=m.split('|')
                  @case_lists[0].appendItem featurehead
                  @case_lists[1].appendItem featurebody
                  @case_lists[2].appendItem featuredc
                end
              end
            end
          rescue SOAP::PostUnavailableError => ex
            getApp().endWaitCursor
            FXMessageBox.error(self, MBOX_OK, "SOAP Error", ex.message)
          end
        end
      end
    end

    # Set up data targets for the product-specific information
    @dir = FXDataTarget.new("")
    @description = FXDataTarget.new("")

    # Information appears on the right-hand side
    mainFrame = FXVerticalFrame.new(splitter, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT|FRAME_SUNKEN|FRAME_THICK)
    mainFrame.shadowColor = FXRGB(248, 248, 255)
    # Switcher
    @tabbook = FXTabBook.new(mainFrame,:opts => LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT|FRAME_THICK,:padLeft => 3, :padRight => 3, :padTop => 3, :padBottom => 3)
    @tabbook.shadowColor = FXRGB(248, 248, 255)
    # First item is a list
    @tab1 = FXTabItem.new(@tabbook, "CaseList", nil)
    @tab1.shadowColor = FXRGB(248, 248, 255)
    infoFrame = FXVerticalFrame.new(@tabbook, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT|FRAME_THICK|FRAME_RAISED)
    infoFrame.shadowColor = FXRGB(248, 248, 255)
    # Second item is a file list
    @tab2 = FXTabItem.new(@tabbook, "web", nil)
    @tab2.shadowColor = FXRGB(248, 248, 255)
    scrollbox_tab2=FXScrollWindow.new(@tabbook)
    configBox_tab2 = FXVerticalFrame.new(scrollbox_tab2, FRAME_THICK|LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y,
                                    :padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0,
                                      :hSpacing => 0, :vSpacing => 0)
    configBox_tab2.baseColor = FXRGB(248, 248, 255)
    config_hash_tab2 = YAML.load(File.open("#{Dir.pwd}\\web\\config.yml"))
    creatCongif config_hash_tab2,configBox_tab2,type='web'
    @tab3 = FXTabItem.new(@tabbook, "api", nil)
    @tab3.shadowColor = FXRGB(248, 248, 255)
    scrollbox_tab3=FXScrollWindow.new(@tabbook)
    configBox_tab3 = FXVerticalFrame.new(scrollbox_tab3, FRAME_THICK|LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y,
                                         :padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0,
                                         :hSpacing => 0, :vSpacing => 0)
    configBox_tab3.baseColor = FXRGB(248, 248, 255)
    config_hash_tab3 = YAML.load(File.open("#{Dir.pwd}\\api\\config.yml"))
    creatCongif config_hash_tab3,configBox_tab3,type='api'
    @tab4 = FXTabItem.new(@tabbook, "app", nil)
    @tab4.shadowColor = FXRGB(248, 248, 255)
    scrollbox_tab4=FXScrollWindow.new(@tabbook)
    configBox_tab4 = FXVerticalFrame.new(scrollbox_tab4, FRAME_THICK|LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y,
                                         :padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0,
                                         :hSpacing => 0, :vSpacing => 0)
    configBox_tab4.baseColor = FXRGB(248, 248, 255)
    config_hash_tab4 = YAML.load(File.open("#{Dir.pwd}\\api\\config.yml"))
    creatCongif config_hash_tab4,configBox_tab4,type='web'

    # Third item is a directory list
    @tab5 = FXTabItem.new(@tabbook, "Result", nil)
    @tab5.shadowColor = FXRGB(248, 248, 255)
    contents = FXVerticalFrame.new(@tabbook,
                                   FRAME_THICK|FRAME_RAISED)
    contents.shadowColor = FXRGB(248, 248, 255)
    # Make header control
    @header1 = FXHeader.new(contents,
                            :opts => HEADER_BUTTON|HEADER_RESIZE|FRAME_RAISED|FRAME_THICK|LAYOUT_FILL_X)
    @header1.shadowColor = FXRGB(248, 248, 255)
    @header1.connect(SEL_CHANGED) do |sender, sel, which|
      @lists[which].width = @header1.getItemSize(which)
    end
    @header1.connect(SEL_COMMAND) do |sender, sel, which|
      @lists[which].numItems.times do |i|
        @lists[which].selectItem(i)
      end
    end

    # Document icon
    doc = nil


    @header1.appendItem("ResultList", doc, 150)
    @header1.appendItem("Hash", nil, 170)
    @header1.appendItem("FeatureName", doc, 230)
    @header1.appendItem("Status", nil, 80)

    # Below header
    panes = FXHorizontalFrame.new(contents,
                                  FRAME_THICK|FRAME_RAISED|LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y,
                                  :padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0,
                                  :hSpacing => 0, :vSpacing => 0)
    panes.shadowColor = FXRGB(248, 248, 255)
    # Make 4 lists
    @lists = []
    @lists.push(FXList.new(panes, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_BROWSESELECT,   :width => 150))
    @lists.push(FXList.new(panes, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_SINGLESELECT,   :width => 170))
    @lists.push(FXList.new(panes, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_MULTIPLESELECT, :width => 230))
    @lists.push(FXList.new(panes, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_EXTENDEDSELECT, :width => 80))

    #@lists[0].backColor = FXRGB(255, 240, 240)
    #@lists[1].backColor = FXRGB(240, 255, 240)
    #@lists[2].backColor = FXRGB(240, 240, 255)
    #@lists[3].backColor = FXRGB(255, 255, 240)

    # Add some contents
    @array=[]
    traverse_dir_base("#{Dir.pwd}\\results")
    @array.each do|n|
      @lists[0].appendItem n
    end

    @lists[0].connect(SEL_COMMAND) { |sender, sel, ptr|
      @array_yaml=[]
      traverse_dir_yaml(Dir.pwd+'\results\\'+(@lists[0].getItem sender.anchorItem).to_s)
      @lists[1].clearItems
      @lists[2].clearItems
      @lists[3].clearItems
      @array_yaml.each do|n|
        @lists[1].appendItem (unicode_utf8 n)
      end
      @lists[1].connect(SEL_COMMAND) { |sender1, sel, ptr|
        @lists[2].clearItems
        @lists[3].clearItems
        data  = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem sender.anchorItem).to_s+'\\'+(@lists[1].getItem sender1.anchorItem).to_s))
        if data!= false
          data['features_suite'].each do |n|
            @lists[2].appendItem(n['feature_name'])
            @lists[3].appendItem(n['feature_ruslt'])
          end
        end
      }
    }

    @lists[0].connect(SEL_RIGHTBUTTONPRESS) { |sender, sel, ptr|
      Dir.foreach(Dir.pwd+'\results\\'+(@lists[0].getItem sender.anchorItem).to_s) do |file|
        if file.to_s.match(/\.*html/)!=nil
          system("C:\\Users\\yangteng\\\AppData\\Roaming\\360se6\\Application\\360se.exe #{"#{Dir.pwd}\\results\\"+(@lists[0].getItem sender.anchorItem).to_s+'\\'+unicode_utf8(file)}")
        end
      end
    }


    # Group box with some controls
    groupie = FXGroupBox.new(panes, "Control",
                              LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE)
    refreshButton = FXButton.new(groupie,"featchAll",:opts => FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT,:padLeft => 10, :padRight => 10, :padTop => 5, :padBottom => 5)
    refreshButton.shadowColor = FXRGB(248, 248, 255)
    refreshButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      @array=[]
      @lists[0].clearItems
      traverse_dir_base(Dir.pwd+'\results')
      @array.each do|n|
        @lists[0].appendItem n
      end
    }

    reRunButton = FXButton.new(groupie,"reRun",:opts => FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT,:padLeft => 10, :padRight => 10, :padTop => 5, :padBottom => 5)
    reRunButton.shadowColor = FXRGB(248, 248, 255)
    reRunButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      rerun_hash = Hash.new()
      array=[]
      @lists[2].each do |n|
        if n.selected?
          time = Time.now.strftime "%Y-%m-%d_%H%M%S"
          report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
          report_hash['features_suite'].each do |m|
            if m['feature_name']==n.to_s
              array<<m['features_suite_name']+' | '+m['feature_name']+' |'+m['feature_name_desc'] if m['feature_name']==n.to_s
              break
            end
          end
        end
        rerun_hash['rerun']=array
      end
      time = Time.now.strftime "%Y-%m-%d_%H%M%S"
      File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'.yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(rerun_hash, f)}
      require 'optparse'
      options = {}
      options[:output_folder] = File.join(Dir.pwd, "results")
      options[:testcase_file]=("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'.yaml')
      time = Time.now.strftime "%H%M%S"
      if File::dirname( @dir.value).match(/web/)!=nil
        options[:test_type]="web"
        require_relative 'web/lib/requires'
        require_relative 'web/lib/runner_web'
        initialize_project_environment options
        run_test(options)
        find_last_yaml(File.join(Dir.pwd, "results"))
        report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
        rerun_hash = YAML.load(File.open(@last_yaml))
        report_hash['features_suite'].each_index do |m|
          rerun_hash['features_suite'].each do |n|
            if report_hash['features_suite'][m]['feature_name']==n['feature_name']
              report_hash['features_suite'][m]=n
            end
          end
        end
        time = Time.now.strftime "%H%M%S"
        File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'(YAML).yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(report_hash, f)}
        initialize_htmlReport("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s)
        set_htmlReport(report_hash)
        end_htmlReport
      end
      if File::dirname( @dir.value).match(/bill/)!=nil
        options[:test_type]="bill"
        require_relative 'bill/lib/requires'
        require_relative 'bill/lib/runner_bill'
        initialize_project_environment options
        run_test(options)
        find_last_yaml(File.join(Dir.pwd, "results"))
        report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
        rerun_hash = YAML.load(File.open(@last_yaml))
        report_hash['features_suite'].each_index do |m|
          rerun_hash['features_suite'].each do |n|
            if report_hash['features_suite'][m]['feature_name']==n['feature_name']
              report_hash['features_suite'][m]=n
            end
          end
        end
        time = Time.now.strftime "%H%M%S"
        File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'(YAML).yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(report_hash, f)}
        initialize_htmlReport("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s)
        set_htmlReport(report_hash)
        end_htmlReport
      end
      if File::dirname( @dir.value).match(/api/)!=nil
        options[:test_type]="api"
        require_relative 'api/lib/requires'
        require_relative 'api/lib/runner_api'
        initialize_project_environment options
        run_test(options)
        find_last_yaml(File.join(Dir.pwd, "results"))
        report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
        rerun_hash = YAML.load(File.open(@last_yaml))
        report_hash['features_suite'].each_index do |m|
          rerun_hash['features_suite'].each do |n|
            if report_hash['features_suite'][m]['feature_name']==n['feature_name']
              report_hash['features_suite'][m]=n
            end
          end
        end
        time = Time.now.strftime "%H%M%S"
        File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'(YAML).yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(report_hash, f)}
        initialize_htmlReport("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s)
        set_htmlReport(report_hash)
        end_htmlReport
      end
      if File::dirname( @dir.value).match(/android/)!=nil
        options[:test_type]="android"
        require_relative 'android/lib/requires'
        require_relative 'android/lib/runner_android'
        initialize_project_environment options
        run_test(options)
        find_last_yaml(File.join(Dir.pwd, "results"))
        report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
        rerun_hash = YAML.load(File.open(@last_yaml))
        report_hash['features_suite'].each_index do |m|
          rerun_hash['features_suite'].each do |n|
            if report_hash['features_suite'][m]['feature_name']==n['feature_name']
              report_hash['features_suite'][m]=n
            end
          end
        end
        time = Time.now.strftime "%H%M%S"
        File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'(YAML).yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(report_hash, f)}
        initialize_htmlReport("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s)
        set_htmlReport(report_hash)
        end_htmlReport
      end
      if File::dirname( @dir.value).match(/ios/)!=nil
        options[:test_type]="ios"
        require_relative 'ios/lib/requires'
        require_relative 'ios/lib/runner_ios'
        initialize_project_environment options
        run_test(options)
        find_last_yaml(File.join(Dir.pwd, "results"))
        report_hash = YAML.load(File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\自动化测试报告(YAML).yaml'))
        rerun_hash = YAML.load(File.open(@last_yaml))
        report_hash['features_suite'].each_index do |m|
          rerun_hash['features_suite'].each do |n|
            if report_hash['features_suite'][m]['feature_name']==n['feature_name']
              report_hash['features_suite'][m]=n
            end
          end
        end
        time = Time.now.strftime "%H%M%S"
        File.open("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s+'\\'+time+'(YAML).yaml', (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(report_hash, f)}
        initialize_htmlReport("#{Dir.pwd}\\results\\"+(@lists[0].getItem @lists[0].anchorItem).to_s)
        set_htmlReport(report_hash)
        end_htmlReport
      end
    }

    #
    infoBox = FXGroupBox.new(infoFrame, "Frame", GROUPBOX_NORMAL|LAYOUT_FILL_X|FRAME_GROOVE|LAYOUT_CENTER_X)
    infoBox1 = FXGroupBox.new(infoFrame, "Pane", GROUPBOX_NORMAL|LAYOUT_FILL_X|FRAME_GROOVE|LAYOUT_CENTER_X)
    infoMatrix = FXMatrix.new(infoBox, 2, MATRIX_BY_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    infoMatrix1 = FXMatrix.new(infoBox1, 7, MATRIX_BY_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y)

    FXLabel.new(infoMatrix, "dir:",:opts =>LAYOUT_FILL_X|LAYOUT_FILL_Y )
    FXTextField.new(infoMatrix, 60, @dir, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    runButton = FXButton.new(infoMatrix1,"Run")
    runButton.shadowColor = FXRGB(248, 248, 255)
    runButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      require 'optparse'
      if File::dirname( @dir.value).match(/web/)!=nil
        options = {}
        options[:output_folder] = File.join(Dir.pwd, "results")
        options[:testcase_file]=@dir.value
        options[:test_type]="web"
        require_relative Dir.pwd+'/web/lib/requires'
        require_relative Dir.pwd+'/web/lib/runner_web'
        initialize_project_environment options
        run_test(options)
      end
      if File::dirname( @dir.value).match(/api/)!=nil
        options = {}
        options[:output_folder] = File.join(Dir.pwd, "results")
        options[:testcase_file]=@dir.value
        options[:test_type]="api"
        require_relative 'api/lib/requires'
        require_relative 'api/lib/runner_api'
        initialize_project_environment options
        run_test(options)
      end
      if File::dirname( @dir.value).match(/android/)!=nil
        options = {}
        options[:output_folder] = File.join(Dir.pwd, "results")
        options[:testcase_file]=@dir.value
        options[:test_type]="android"
        require_relative 'android/lib/requires'
        require_relative 'android/lib/runner_android'
        initialize_project_environment options
        run_test(options)
      end
      if File::dirname( @dir.value).match(/ios/)!=nil
        options = {}
        options[:output_folder] = File.join(Dir.pwd, "results")
        options[:testcase_file]=@dir.value
        options[:test_type]="ios"
        require_relative 'ios/lib/requires'
        require_relative 'ios/lib/runner_ios'
        initialize_project_environment options
        run_test(options)
      end
      if File::dirname( @dir.value).match(/bill/)!=nil
        options = {}
        options[:output_folder] = File.join(Dir.pwd, "results")
        options[:testcase_file]=@dir.value
        options[:test_type]="bill"
        require_relative 'bill/lib/requires'
        require_relative 'bill/lib/runner_bill'
        initialize_project_environment options
        run_test(options)
      end
    }
    saveAsButton = FXButton.new(infoMatrix1,"SaveAs")
    saveAsButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      time = Time.now.strftime "%Y-%m-%d_%H%M%S"
      newfeature_arr = Array.new
      for i in 0..(@case_lists[0].numItems-1)
        newfeature_arr<<((@case_lists[0].getItem i).to_s+"|"+(@case_lists[1].getItem i).to_s+"|"+(@case_lists[2].getItem i).to_s)
      end
      newfeature_hash = Hash.new
      newfeature_hash.store(time,newfeature_arr)
      File.open(File::dirname( @dir.value)+"/#{time}.yml", (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(newfeature_hash, f)}
      @treeList.clearItems
      webItem = @treeList.appendItem(nil, 'web')
      apiItem = @treeList.appendItem(nil, 'api')
      iosItem = @treeList.appendItem(nil, 'ios')
      androidItem = @treeList.appendItem(nil, 'android')
      billItem = @treeList.appendItem(nil, 'bill')
      @productTree = []
      traverse_dir_file(Dir.pwd+'\web\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        webListItem = @treeList.appendItem(webItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\api\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        apiListItem = @treeList.appendItem(apiItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\ios\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        iosListItem = @treeList.appendItem(iosItem, sectionName)
      end
      @productTree = []
      traverse_dir_file(Dir.pwd+'\android\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        androidListItem = @treeList.appendItem(androidItem, sectionName)
      end#
      @productTree = []
      traverse_dir_file(Dir.pwd+'\bill\testcases')
      @productTree.sort.each do |sectionName|
        #sectionHash = @productTree[sectionName]
        billListItem = @treeList.appendItem(billItem, sectionName)
      end#
    }
    saveAsButton.shadowColor = FXRGB(248, 248, 255)
    deleteItemButton = FXButton.new(infoMatrix1,"DeleteItem")
    deleteItemButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      for i in 0..(@case_lists[0].numItems-1)
        if (@case_lists[0].getItem i).selected?
          @case_lists[0].removeItem i
          @case_lists[1].removeItem i
          @case_lists[2].removeItem i
          break
        end
      end
    }
    deleteItemButton.shadowColor = FXRGB(248, 248, 255)

    upItemButton = FXButton.new(infoMatrix1,"UPItem")
    upItemButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      for i in 0..(@case_lists[0].numItems-1)
        if (@case_lists[0].getItem i).selected? and i-1>=0
          @case_lists[0].moveItem i,i-1
          @case_lists[1].moveItem i,i-1
          @case_lists[2].moveItem i,i-1
          break
        end
      end
    }
    upItemButton.shadowColor = FXRGB(248, 248, 255)

    downItemButton = FXButton.new(infoMatrix1,"DownItem")
    downItemButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      for i in 0..(@case_lists[0].numItems-1)
        if (@case_lists[0].getItem i).selected? and  (i+1)!=@case_lists[0].numItems
          @case_lists[0].moveItem i,i+1
          @case_lists[1].moveItem i,i+1
          @case_lists[2].moveItem i,i+1
          break
        end
      end
    }
    downItemButton.shadowColor = FXRGB(248, 248, 255)



    testCaseBoxButton = FXButton.new(infoMatrix1,"TestCaseBox")
    testCaseBoxButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      FXEditDialog.new(self,@url,@dir,@treeList).execute
    }
    testCaseBoxButton.shadowColor = FXRGB(248, 248, 255)
    featureBoxButton = FXButton.new(infoMatrix1,"featureBox")
    featureBoxButton.connect(SEL_COMMAND) { |sender, sel, ptr|
      FXFeatureDialog.new(self,@caseEnv,@dir,@treeList,@case_lists).execute
    }
    featureBoxButton.shadowColor = FXRGB(248, 248, 255)
    descriptionBox = FXGroupBox.new(infoFrame, "Description", GROUPBOX_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_GROOVE|LAYOUT_SIDE_BOTTOM)
    descriptionFrame = FXHorizontalFrame.new(descriptionBox, FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    @case_lists=[]
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_SINGLESELECT,   :width => 150))
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_SINGLESELECT,   :width => 350))
    @case_lists.push(FXList.new(descriptionFrame, :opts => LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LIST_SINGLESELECT,   :width => 350))
    @case_lists[0].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[1].selectItem sender.anchorItem
      @case_lists[2].selectItem sender.anchorItem
    }
    @case_lists[1].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[0].selectItem sender.anchorItem
      @case_lists[2].selectItem sender.anchorItem
    }
    @case_lists[2].connect(SEL_COMMAND) { |sender, sel, ptr|
      @case_lists[0].selectItem sender.anchorItem
      @case_lists[1].selectItem sender.anchorItem
    }

    # Initialize the service
    #@raa = SOAP::WSDLDriverFactory.new("http://www2.ruby-lang.org/xmlns/soap/interface/RAA/0.0.4/").create_rpc_driver

    # Set up the product tree list

    @treeList.clearItems
    webItem = @treeList.appendItem(nil, 'web')
    apiItem = @treeList.appendItem(nil, 'api')
    iosItem = @treeList.appendItem(nil, 'ios')
    androidItem = @treeList.appendItem(nil, 'android')
    billItem = @treeList.appendItem(nil, 'bill')
    @productTree = []
    traverse_dir_file(Dir.pwd+'\web\testcases')
    @productTree.sort.each do |sectionName|
      #sectionHash = @productTree[sectionName]
      webListItem = @treeList.appendItem(webItem, sectionName)
    end#
    @productTree = []
    traverse_dir_file(Dir.pwd+'\api\testcases')
    @productTree.sort.each do |sectionName|
      #sectionHash = @productTree[sectionName]
      apiListItem = @treeList.appendItem(apiItem, sectionName)
    end
    @productTree = []
    traverse_dir_file(Dir.pwd+'\ios\testcases')
    @productTree.sort.each do |sectionName|
      #sectionHash = @productTree[sectionName]
      iosListItem = @treeList.appendItem(iosItem, sectionName)
    end
    @productTree = []
    traverse_dir_file(Dir.pwd+'\android\testcases')
    @productTree.sort.each do |sectionName|
      #sectionHash = @productTree[sectionName]
      androidListItem = @treeList.appendItem(androidItem, sectionName)
    end
    @productTree = []
    traverse_dir_file(Dir.pwd+'\bill\testcases')
    @productTree.sort.each do |sectionName|
      #sectionHash = @productTree[sectionName]
      billListItem = @treeList.appendItem(billItem, sectionName)
    end#
  end

  def create
    super
    @treeList.parent.parent.setWidth(@treeList.font.getTextWidth('M'*24))
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  app = FXApp.new("RAABrowser", "FoxTest")
  RAABrowserWindow.new(app)
  app.create
  app.run
end