#include "ui_effects.as"
#include "ui_tools.as"

enum EndScreenState {
    agsFighting,
    agsMsgScreen,
    agsEndScreen,
    agsInvalidState
};

const int _text_size = 60;
const int _challenge_text_size = 120;
const vec4 _text_color = vec4(0.8, 0.8, 0.8, 1.0);

class EndScreen : AHGUI::GUI {
    private bool show_controls = false;
    private float time = 0;
    string message = "default message";

    private EndScreenState current_state = agsFighting;
    private EndScreenState last_state = agsInvalidState;

    EndScreen(){
        super();
    }

    void handleStateChange(){
        if(last_state == current_state){
            return;
        }
        last_state = current_state;
        clear();
        switch(current_state){
            case agsInvalidState:{
                DisplayError("GUI Error", "GUI in invalid state");
            }
            break;
            case agsMsgScreen:
            case agsEndScreen:{
                ShowEndScreenUI();
            }
        }
    }

    void ShowEndScreenUI(){
        AHGUI::Divider@ mainPane = root.addDivider(DDTop, DOVertical, ivec2( 2562, 1440 ));
        mainPane.setHorizontalAlignment(BALeft);
        AHGUI::Divider@ title1 = mainPane.addDivider( DDTop, DOHorizontal, ivec2( AH_UNDEFINEDSIZE, 350 ));
        DisplayText(title1, DDCenter, message, _text_size, _text_color, true);

        AHGUI::Divider@ scorePane = mainPane.addDivider( DDTop, DOVertical, ivec2( AH_UNDEFINEDSIZE, 300 ));
        DisplayText(scorePane, DDTop, "Your time: " + GetTime(int(time)), _text_size, _text_color, true);

        if(show_controls){
            AHGUI::Divider@ footer = mainPane.addDivider( DDBottom, DOHorizontal, ivec2( AH_UNDEFINEDSIZE, 300 ));
            DisplayText(footer, DDCenter, "Press escape to return to menu or space to restart", _text_size, _text_color, true);
        }
    }

    string GetTime(int seconds){
        int numSeconds = seconds % 60;
        int numMinutes = seconds / 60;
        if(numMinutes == 0){
            return numSeconds + " seconds";
        }else if(numMinutes == 1){
            return numMinutes + " minute and " + numSeconds + " seconds";
        }else{
            return numMinutes + " minutes and " + numSeconds + " seconds";
        }
    }

    void Update() {
        handleStateChange();
        AHGUI::GUI::update();
    }

    void Reset(){
        current_state = agsFighting;
        show_controls = false;
    }

    void Render() {
       hud.Draw();
       AHGUI::GUI::render();
    }

    void DisplayText(AHGUI::Divider@ div, DividerDirection dd, string text, int _text_size, vec4 color, bool shadowed, string textName = "foo"){
        AHGUI::Text singleSentence(text, "OpenSans-Regular", _text_size, color.x, color.y, color.z, color.a);
        singleSentence.setName(textName);
        singleSentence.setShadowed(shadowed);
        div.addElement(singleSentence, dd);
        singleSentence.setBorderSize(1);
        singleSentence.setBorderColor(1.0, 1.0, 1.0, 1.0);
        singleSentence.showBorder(false);
    }

    void ShowMessage(string _message, float _time){
        time = _time;
        message = _message;
        current_state = agsMsgScreen;
    }

    void ShowControls(){
        show_controls = true;
        current_state = agsEndScreen;
    }
}
