require 'rubygems'
require 'bundler/setup'

Bundler.require
require 'active_record'
require 'db'


class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language)
  end
end


configure do
  $markdown = Redcarpet::Markdown.new(
    HTMLwithPygments.new(:hard_wrap => true), {
      :autolink => true,
      :tables => true,
      :no_intra_empahsis => true,
      :strikethrough => true,
      :lax_html_blocks => true,
      :fenced_code_blocks => true,
      :space_after_headers => true
    })

  dbconfig = YAML::load(File.open('config/database.yml'))

  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.establish_connection(dbconfig)

  ActiveRecord::Base.include_root_in_json = false
end


get '/' do
  haml :main, :format => :html5
end


get '/project' do
  #:limit =>, :offset =>
  Project.where("project_id = ?", params[:project_id]).to_json
end


get '/tags' do
  Tag.where("project_id = ?", params[:project_id]).to_json
end


get '/tasks' do
  Task.where("project_id = ?", params[:project_id]).to_json
end


get '/notes' do
  Note.where("project_id = ?", params[:project_id]).to_json
end


post '/note_add' do
  begin
    p = Project.find(params[:project_id])
    n = p.notes.create!(:text => params[:note_text])
    n.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/note_addtag' do
  begin
    n = Note.find(params[:note_id])
    t = Tag.find(params[:tag_id])

    n.tags << t
    n.save!
    n.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/note_deletetag' do
  begin
    nt = NoteTag.where("note_id = ? AND tag_id = ?", params[:note_id], params[:tag_id]).limit(1)
    #nt = NoteTag.get(params[:note_id], params[:tag_id])
    NoteTag.destroy(nt)

    n = Note.find(params[:note_id])
    n.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/note_delete' do
  begin
    n = Note.find(params[:note_id])
    Note.destroy(n)
    {}.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/tag_add' do
  begin
    p = Project.find(params[:project_id])
    t = p.tags.create!(:name => params[:tag_name])
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/tag_update' do
  begin
    t = Tag.find(params[:tag_id])
    t.name = params[:tag_name]
    t.color = params[:tag_color]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/tag_changecolor' do
  begin
    t = Tag.find(params[:tag_id])
    t.color = params[:tag_color]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/tag_changename' do
  begin
    t = Tag.find(params[:tag_id])
    t.name = params[:tag_name]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/tag_delete' do
  begin
    t = Tag.find(params[:tag_id])
    Tag.destroy(t)
    {}.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end



post '/task_add' do
  begin
    p = Project.find(params[:project_id])
    t = p.tasks.create!(:summary => params[:task_summary])
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_delete' do
  begin
    t = Task.find(params[:task_id])
    Task.destroy(t)
    {}.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_block' do
  begin
    t = Task.find(params[:task_id])
    if params[:task_block] == "no"
      t.blocked = false
    elsif params[:task_block] == "yes"
      t.blocked = true
    end
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_adddep' do
  begin
    t = Task.find(params[:task_id])

    #if TaskDep.get(params[:task_id], params[:task_dep_id]) == nil
    tdep = Task.find(params[:task_dep_id])
    dep = TaskDep.create!(:task => t, :dependency => tdep)

    t.deps << dep

    t.save!

    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_deletedep' do
  begin
    dep = TaskDep.where("task_id = ? AND dependency_id = ?", params[:task_id], params[:task_dep_id])
    TaskDep.destroy(dep)

    t = Task.find(params[:task_id])
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_addtag' do
  begin
    task = Task.find(params[:task_id])
    t = Tag.find(params[:tag_id])

    task.tags << t
    task.save!
    task.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_deletetag' do
  begin
    tt = TaskTag.where("task_id = ? AND tag_id = ?", params[:task_id], params[:tag_id])
    TaskTag.destroy(tt)

    t = Task.find(params[:task_id])
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_complete' do
  begin
    t = Task.find(params[:task_id])
    t.completed = true
    t.save!
    t.to_json_ex
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_uncomplete' do
  begin
    t = Task.find(params[:task_id])
    t.completed = false
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_changeimportance' do
  begin
    t = Task.find(params[:task_id])
    t.importance = params[:task_importance]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_changesummary' do
  begin
    t = Task.find(params[:task_id])
    t.summary = params[:task_summary]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


post '/task_changetext' do
  begin
    t = Task.find(params[:task_id])
    t.text = params[:task_text]
    t.save!
    t.to_json
  rescue ActiveRecord::RecordInvalid => e
    e.errors_to_json
  end
end


get '/projects' do
  Project.all.to_json
end


get '/db_populate' do
  p = Project.create(:name => 'mrf24j40-driver', :github_repo => 'bwalex/mrf24j40-driver')
  tag1 = p.tags.create(:color => '#00ff00', :name => 'Tag1')
  tag2 = p.tags.create(:color => '#0000ff', :name => 'Tag2')
  tag3 = p.tags.create(:color => '#00ffff', :name => 'Tag3')
  tag4 = p.tags.create(:color => '#ffff00', :name => 'Tag4')
  tag5 = p.tags.create(:color => '#ff00ff', :name => 'Tag5')
  p.tags.create(:color => '#eebbcc', :name => 'Tag Master 6')
  p.tags.create(:color => '#F3918F', :name => 'Long Tag Number 7')
  p.tags.create(:color => '#391AAA', :name => 'Another long tag 8')
  p.tags.create(:color => '#13dfa9', :name => 'taggi tag')
  p.tags.create(:color => '#316131', :name => 'moo tag')
  p.tags.create(:color => '#986301', :name => 'meh tag')
  p.tags.create(:color => '#750931', :name => 'foo tag')
  p.tags.create(:color => '#865dfa', :name => 'Very, very, extremely long, tag')

  n = p.notes.create(:text => 'Next time I need to revise the initial PCB layout')
  n.tags << tag1
  n.tags << tag5
  n.save

  n = p.notes.create(:text => 'Last time I tried to debug some SPI issue with some italian guy')
  n.tags << tag1
  n.tags << tag2
  n.tags << tag3
  n.save

  t1 = p.tasks.create(:summary => 'Take garbage out')
  t1.tags << tag2
  t1.tags << tag4
  t1.save


  t2 = p.tasks.create(:summary => 'Finish this web app', :importance => 'high')
  t2.tags << tag1
  t2.tags << tag3
  t2.tags << tag4
  t2.tags << tag5
  t2.save

  t = p.tasks.create(:summary => 'Pick up parcels', :importance => 'low')
  t.tags << tag3
  dep = TaskDep.create(:task => t, :dependency => t1)
  t.task_deps << dep
  dep = TaskDep.create(:task => t, :dependency => t2)
  t.task_deps << dep
  t.save

  p = Project.create(:name => 'tc-play', :github_repo => 'bwalex/tc-play')
  p = Project.create(:name => 'sniff802154')
end


not_found do
  "This is not the web page you are looking for."
end




#error do
#end
