module Home exposing (..)

import Domain.Core exposing (..)
import Controls.Login as Login exposing (..)
import Tests.TestAPI as TestAPI exposing (tryLogin)
import Services.Server as Services exposing (tryLogin)
import Html exposing (..)
import Html.Attributes exposing (..)


main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }



-- CONFIGURATION


configuration : Configuration
configuration =
    Isolation


type Configuration
    = Integration
    | Isolation


type alias Dependencies =
    { tryLogin : Loginfunction, tagUrl : TagUrlFunction }


runtime : Dependencies
runtime =
    case configuration of
        Integration ->
            Dependencies Services.tryLogin Services.tagUrl

        Isolation ->
            Dependencies TestAPI.tryLogin TestAPI.tagUrl



-- MODEL


type alias Content =
    { videos : List Video
    , articles : List Article
    , podcasts : List Podcast
    }


type alias Model =
    { content : Content
    , submitters : List Submitter
    , login : Login.Model
    }


model : Model
model =
    { content = Content [] [] []
    , submitters = []
    , login = Login.model
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- UPDATE


type Msg
    = Video Video
    | Article Article
    | Submitter Submitter
    | Search String
    | Register
    | OnLogin Login.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        Video v ->
            model

        Article v ->
            model

        Submitter v ->
            model

        Search v ->
            model

        Register ->
            model

        OnLogin subMsg ->
            case subMsg of
                Login.Attempt v ->
                    let
                        latest =
                            Login.update subMsg model.login
                    in
                        { model | login = runtime.tryLogin latest }

                Login.UserInput _ ->
                    { model | login = Login.update subMsg model.login }

                Login.PasswordInput _ ->
                    { model | login = Login.update subMsg model.login }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ header []
            [ label [] [ text "Nikeza" ]
            , model |> sessionUI
            ]
        , div [] submitters
        , footer [ class "copyright" ]
            [ label [] [ text "(c)2017" ]
            , a [ href "" ] [ text "GitHub" ]
            ]
        ]


submitters : List (Html Msg)
submitters =
    TestAPI.recentSubmitters |> List.map thumbnail


thumbnail : Profile -> Html Msg
thumbnail profile =
    let
        formatTag tag =
            a [ href <| getUrl <| tagUrl runtime.tagUrl profile.id tag ] [ i [] [ text <| getTag tag ] ]

        concatTags tag1 tag2 =
            span []
                [ tag1
                , label [] [ text " " ]
                , tag2
                , label [] [ text " " ]
                ]

        tags =
            List.foldr concatTags (div [] []) (profile.tags |> List.map formatTag)

        tagsAndBio =
            div []
                [ tags
                , br [] []
                , label [] [ text profile.bio ]
                ]
    in
        div []
            [ table []
                [ tr []
                    [ td [] [ img [ src <| getUrl profile.imageUrl, width 50, height 50 ] [] ]
                    , td [] [ tagsAndBio ]
                    ]
                ]
            , label [] [ text (profile.name |> getName) ]
            ]


sessionUI : Model -> Html Msg
sessionUI model =
    let
        loggedIn =
            model.login.loggedIn

        welcome =
            p [] [ text <| "Welcome " ++ model.login.username ++ "!" ]

        signout =
            a [ href "" ] [ label [] [ text "Signout" ] ]
    in
        if (not loggedIn) then
            Html.map OnLogin <| Login.view model.login
        else
            div [ class "signin" ] [ welcome, signout ]
