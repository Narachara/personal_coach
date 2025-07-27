use dioxus::prelude::*;

const MAIN_CSS: Asset = asset!("/assets/main.css");


fn main() {
    dioxus::launch(App);
}

#[component]
fn App() -> Element {
    rsx! {
        document::Link { rel: "stylesheet", href: MAIN_CSS }
        Hero {}

    }
}

#[component]
pub fn Hero() -> Element {
    rsx! {
        div {
            p {"welcome to my app"}
        }
    }
}
