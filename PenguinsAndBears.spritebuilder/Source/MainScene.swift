import Foundation

class MainScene: CCNode {

    func didLoadFromCCB() {
        NSLog("Loaded")
    }
    
    func play() {
        var gameScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().replaceScene(gameScene)
        NSLog("Play Button Clicked")
    }
}
