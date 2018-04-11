# 快速开始

下载 `dist/rgui.rb` 文件，然后将其拷贝到 `RMVA` 的插入脚本处。然后在你的界面脚本里 `include RGUI::Component`。 

## 一个标题场景的例子
```ruby
class Scene_Title < Scene_Base
  include RGUI::Component
  def start
    super
    SceneManager.clear
    play_title_music
    create
  end

  def create
    @background = ImageBox.new({
      image: Cache.picture('bg'),
      type: ImageBoxType::Responsive})
    @title = RGUI::Component::Label.new({
          width: Graphics.width,
          height: Graphics.height / 2,
          text: $data_system.game_title,
          size: 56
    })
    @start_btn = SpriteButton.new({
      x: 80,
      y: 260,
      images: Cache.picture('start').cut_bitmap(3, 0)
    })
    @start_btn.event_manager.on(:keyup_MOUSE_LB){
      DataManager.setup_new_game
      SceneManager.scene.fadeout_all
      $game_map.autoplay
      SceneManager.goto(Scene_Map)
    }
    @load_btn = SpriteButton.new({
      x: 80,
      y: 300,
      images: Cache.picture('load').cut_bitmap(3, 0)
    })
    @load_btn.event_manager.on(:keyup_MOUSE_LB){
      SceneManager.call(Scene_Load)
    }
    @exit_btn = SpriteButton.new({
      x: 80,
      y: 340,
      images: Cache.picture('exit').cut_bitmap(3, 0)
    })
    @exit_btn.event_manager.on(:keyup_MOUSE_LB){
      SceneManager.scene.fadeout_all
      SceneManager.exit
    }
  end

  def update
    super
    @start_btn.update
    @load_btn.update
    @exit_btn.update
  end
  
  def terminate
    @background.dispose
    @title.dispose
    @start_btn.dispose
    @load_btn.dispose
    @exit_btn.dispose
  end

  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
end
```