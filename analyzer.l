%{
    #include <iostream>
    #include <string>
    #include <vector>
    using namespace std;

    /* Structura pentru a retine informatii despre tag-urile din body */
    struct Tag {
        string name;
        bool is_div;
        vector<string> attributes;
        vector<Tag> divTags;
    };

    /* Structura pentru a retine informatii despre tag-urile din style */
    struct Style {
        string name;
        vector<string> attributes;
    };

    /* Vector pentru a retine tagurile intalnite in body, respectiv style */
    vector<Tag> bodyTags;
    vector<Style> headTags;

    int div_number = 0;
    int tags_in_tag = 0;
%}

%option noyywrap

/* Stari */
%s VOID_IN_TAG_IN_TAG
%s TAG_IN_TAG
%s VOID_IN_TAG_IN_BODY
%s VOID_IN_TAG_IN_TAG_IN_DIV
%s TAG_IN_TAG_IN_DIV
%s VOID_IN_TAG_IN_DIV
%s TAG_IN_DIV
%s VOID_IN_DIV
%s VOID_IN_BODY
%s DIV_IN_BODY
%s TAG_IN_BODY
%s IN_BODY
%s IN_STYLE_TAG
%s IN_STYLE
%s IN_HEAD

/* Expresii regulate */

/* Sintaxa unui tag din body si atributele lui */
TAG [a-zA-Z0-9]+
ATTRIBUTE [a-zA-Z0-9]+"="

/* Sintaxa unui tag din style si atributele lui */
STYLE_TAG [a-zA-Z0-9\.]+" {"
STYLE_ATTRIBUTE [a-zA-Z\-]+":"

/* Tag-urile care nu au nevoie de inchidere */
VOID_ELEMENT "area"|"base"|"br"|"col"|"command"|"embed"|"hr"|"img"
VOID_ELEMEN2 "input"|"keygen"|"link"|"meta"|"param"|"source"|"track"|"wbr"

%%

"<head>" {
    /* Am gasit tag-ul pentru head */
    BEGIN(IN_HEAD);
}

"<body>" {
    /* Am gasit tag-ul pentru body */
    BEGIN(IN_BODY);
}

<IN_HEAD>"<style>" {
    /* Am gasit tag-ul <style> in head */
    BEGIN(IN_STYLE);
}

<IN_STYLE>"</style>" {
    /* ies din <style> */
    BEGIN(IN_HEAD);
}

<IN_STYLE>{STYLE_TAG} {
    /* Am gasit un tag in style
       Adaug tag-ul in vectorul corespunzator tag-urilor din style */
    yytext[yyleng - 2] = '\0';
    Style style_tag;
    style_tag.name = yytext;
    headTags.push_back(style_tag);
    BEGIN(IN_STYLE_TAG);
}

<IN_STYLE_TAG>{STYLE_ATTRIBUTE} {
    /* Am gasit un atribut pe care il adaug in vectorul de
       atribute al ultimului tag adaugat in vectorul de tag-uri */
    yytext[yyleng - 1] = '\0';
    headTags.back().attributes.push_back(yytext);
    BEGIN(IN_STYLE_TAG);
}

<IN_STYLE_TAG>"}" {
    /* Am parcurs toate atributele tag-ului curent, ma intorc in <style> */
    BEGIN(IN_STYLE);
}

<IN_BODY>{ATTRIBUTE} {
    /* Nu memorez atributele lui <body> */
    BEGIN(IN_BODY);
}

<IN_BODY>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Am gasit un void element in body */
    Tag tag;
    tag.is_div = false;
    tag.name = yytext;
    bodyTags.push_back(tag);
    BEGIN(VOID_IN_BODY);
}

<IN_BODY>"<div" {
    /* Am gasit <div> in body */
    div_number++;
    tags_in_tag = 0;
    Tag tag;
    tag.is_div = true;
    tag.name = yytext;
    tag.name = tag.name + to_string(div_number);
    bodyTags.push_back(tag);
    BEGIN(DIV_IN_BODY);
}

<IN_BODY>"<"{TAG} {
    /* Am gasit <TAG> in body */
    tags_in_tag++;
    Tag tag;
    tag.is_div = false;
    tag.name = yytext;
    bodyTags.push_back(tag);
    BEGIN(TAG_IN_BODY);
}

<VOID_IN_BODY>">" {
    /* Ajung la sfarsitul atributelor elementului void */
    BEGIN(IN_BODY);
}

<VOID_IN_BODY>{ATTRIBUTE} {
    /* Nu memorez atributele elementului void */
    BEGIN(VOID_IN_BODY);
}

<TAG_IN_BODY>{ATTRIBUTE} {
    /* Memorez atributele ultimului tag gasit */
    yytext[yyleng - 1] = '\0';
    bodyTags.back().attributes.push_back(yytext);
    BEGIN(TAG_IN_BODY);
}

<TAG_IN_BODY>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Am gasit un element void in tag */
    BEGIN(VOID_IN_TAG_IN_BODY);
}

<TAG_IN_BODY>"<"{TAG} {
    /* Am gasit un tag in tag, incrementez numarul de taguri */
    tags_in_tag++;
    BEGIN(TAG_IN_TAG);
}

<TAG_IN_BODY>"</" {
    /* Tagul a fost inchis, ma pot intoarce in body */
    tags_in_tag = 0;
    BEGIN(IN_BODY);
}

<VOID_IN_TAG_IN_BODY>">" {
    /* Ajung la sfarsitul atributelor elementului void */
    BEGIN(TAG_IN_BODY);
}

<VOID_IN_TAG_IN_BODY>{ATTRIBUTE} {
    /* Nu memorez atributele elementului void */
    BEGIN(VOID_IN_TAG_IN_BODY);
}

<TAG_IN_TAG>{ATTRIBUTE} {
    /* Nu memorez atributele gasite */
    BEGIN(TAG_IN_TAG);
}

<TAG_IN_TAG>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Nu memorez elementele void gasite */
    BEGIN(VOID_IN_TAG_IN_TAG);
}

<TAG_IN_TAG>"<"{TAG} {
    /* Am gasit un alt tag in tag, incrementez numarul de taguri din tag */
    tags_in_tag++;
    BEGIN(TAG_IN_TAG);
}

<TAG_IN_TAG>"</" {
    /* Am gasit inchiderea unui tag, decrementez numarul de taguri
       Daca numarul de taguri este 1 inseamna ca sunt in tagul gasit in body */
    tags_in_tag--;
    if (tags_in_tag == 1)
        BEGIN(TAG_IN_BODY);
    else
        BEGIN(TAG_IN_TAG);
}

<VOID_IN_TAG_IN_TAG>">" {
    /* Ajung la sfarsitul atributelor elementului void */
    BEGIN(TAG_IN_TAG);
}

<VOID_IN_TAG_IN_TAG>{ATTRIBUTE} {
    /* Nu memorez atributele elementului void */
    BEGIN(VOID_IN_TAG_IN_TAG);
}

<DIV_IN_BODY>"</div>" {
    /* S-a inchis div-ul, ma intorc in body */
    BEGIN(IN_BODY);
}

<DIV_IN_BODY>{ATTRIBUTE} {
    /* Salvez atributele lui <div> */
    yytext[yyleng - 1] = '\0';
    bodyTags.back().attributes.push_back(yytext);
    BEGIN(DIV_IN_BODY);
}

<DIV_IN_BODY>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Am gasit un element void in <div> */
    Tag tag;
    tag.is_div = false;
    tag.name = yytext;
    bodyTags.back().divTags.push_back(tag);
    BEGIN(VOID_IN_DIV);
}

<DIV_IN_BODY>"<"{TAG} {
    /* Am gasit un <tag> in <div> */
    tags_in_tag++;
    Tag tag;
    tag.is_div = false;
    tag.name = yytext;
    bodyTags.back().divTags.push_back(tag);
    BEGIN(TAG_IN_DIV);
}

<VOID_IN_DIV>{ATTRIBUTE} {
    /* Memorez atributele elementului void gasit in div */
    yytext[yyleng - 1] = '\0';
    bodyTags.back().divTags.back().attributes.push_back(yytext);
    BEGIN(VOID_IN_DIV);
}

<VOID_IN_DIV>">" {
    /* Am gasit toate atributele elementului void */
    BEGIN(DIV_IN_BODY);
}

<TAG_IN_DIV>{ATTRIBUTE} {
    /* Am gasit un tag in div */
    yytext[yyleng - 1] = '\0';
    bodyTags.back().divTags.back().attributes.push_back(yytext);
    BEGIN(TAG_IN_DIV);
}

<TAG_IN_DIV>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Am gasit un element void in tag-ul din div */
    BEGIN(VOID_IN_TAG_IN_DIV);
}

<TAG_IN_DIV>"<"{TAG} {
    /* Am gasit un alt tag in tag-ul principal din div */
    tags_in_tag++;
    BEGIN(TAG_IN_TAG_IN_DIV);
}

<TAG_IN_DIV>"</" {
    /* Am ajuns la inchiderea tag-ului gasit in div */
    tags_in_tag = 0;
    BEGIN(DIV_IN_BODY);
}

<VOID_IN_TAG_IN_DIV>{ATTRIBUTE} {
    /* Nu memorez atributele elementului void gasit in tag */
    BEGIN(VOID_IN_TAG_IN_DIV);
}

<VOID_IN_TAG_IN_DIV>">" {
    /* Am terminat de parcurs atributele elementului void */
    BEGIN(TAG_IN_DIV);
}

<TAG_IN_TAG_IN_DIV>{ATTRIBUTE} {
    /* Nu memorez atributele tag-ului care se afla in tag-ul gasit in main
       sau in alte tag-uri */
    BEGIN(TAG_IN_TAG_IN_DIV);
}

<TAG_IN_TAG_IN_DIV>"<"{VOID_ELEMENT}|"<"{VOID_ELEMEN2} {
    /* Am gasit un element void in tag */
    BEGIN(VOID_IN_TAG_IN_TAG_IN_DIV);
}

<TAG_IN_TAG_IN_DIV>"</" {
    /* Am gasit inchiderea unui tag, decrementez numarul de tag-rui
       Daca numarul de tag-uri este 1, inseamna ca toate tag-urile gasite
       in tag-ul principal din div au fost inchise */
    tags_in_tag--;
    if (tags_in_tag == 1)
        BEGIN(TAG_IN_DIV);
    else
        BEGIN(TAG_IN_TAG_IN_DIV);
}

<TAG_IN_TAG_IN_DIV>"<"{TAG} {
    /* Am gasit alt tag in tag */
    tags_in_tag++;
    BEGIN(TAG_IN_TAG_IN_DIV);
}

<VOID_IN_TAG_IN_TAG_IN_DIV>{ATTRIBUTE} {
    /* Nu memorez atributele elementului void */
    BEGIN(VOID_IN_TAG_IN_TAG_IN_DIV);
}

<VOID_IN_TAG_IN_TAG_IN_DIV>">" {
    /* Am terminat de parcurs toate atributele */
    BEGIN(TAG_IN_TAG_IN_DIV);
}

.|\n ;

%%

int main(int argc, char* argv[]) {
    /* Parsez fisierul HTML */
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);

    /* Afisez tag-urile din <body> */
    cout << endl << "- Tagurile din <body>: " << endl;
    cout << "[";
    for (int i = 0; i < bodyTags.size(); i++) {
        if (i + 1 != bodyTags.size())
            cout << bodyTags[i].name << ">, ";
        else
            cout << bodyTags[i].name << ">";
    }
    cout << "]" << endl;

    /* Afisez tag-urile din fiecare <div> */
    cout << endl << "- Tagurile din <div>: " << endl;
    cout << "[";
    int current_div = 0;
    for (int i = 0; i < bodyTags.size(); i++) {
        if (bodyTags[i].is_div && !bodyTags[i].divTags.empty()) {
            current_div++;
            cout << bodyTags[i].name << ">:[";
            int tags_numbers = bodyTags[i].divTags.size();
            for (int j = 0; j < tags_numbers; j++) {
                if (j + 1 != tags_numbers)
                    cout << bodyTags[i].divTags[j].name << ">, ";
                else
                    cout << bodyTags[i].divTags[j].name << ">";
            }
            if (current_div == div_number)
                cout << "]";
            else
                cout << "]," << endl;
        }
    }
    cout << "]" << endl;

    /* Afisez tag-urile din <style> */
    cout << endl << "- Tagurile din <style>: " << endl;
    cout << "[";
    for (int i = 0; i < bodyTags.size(); i++) {
        if (bodyTags[i].is_div && !bodyTags[i].attributes.empty()) {
            cout << bodyTags[i].name << ">->[";
            int attr_number = bodyTags[i].attributes.size();
            for (int j = 0; j < attr_number; j++) {
                if (j + 1 != attr_number)
                    cout << bodyTags[i].attributes[j] << ", ";
                else
                    cout << bodyTags[i].attributes[j];
            }
            cout << "]," << endl;
        }
    }

    current_div = 0;
    for (int i = 0; i < bodyTags.size(); i++) {
        if (bodyTags[i].is_div && !bodyTags[i].divTags.empty()) {
            current_div++;
            int tags_number = bodyTags[i].divTags.size();
            for (int j = 0; j < tags_number; j++) {
                if (!bodyTags[i].divTags[j].attributes.empty()) {
                    int attr_number = bodyTags[i].divTags[j].attributes.size();
                    cout << bodyTags[i].name << ">->";
                    cout << bodyTags[i].divTags[j].name << ">->[";
                    for (int k = 0; k < attr_number; k++) {
                        if (k + 1 != attr_number)
                            cout << bodyTags[i].divTags[j].attributes[k] << ", ";
                        else
                            cout << bodyTags[i].divTags[j].attributes[k];
                    }
                    cout << "]," << endl;
                }
            }
        }
    }

    if (!headTags.empty()) {
        for (int i = 0; i < headTags.size(); i++) {
            if (!headTags[i].attributes.empty()) {
                cout << "<" << headTags[i].name << ">-> [";
                int attr_number = headTags[i].attributes.size();
                for (int j = 0; j < attr_number; j++) {
                    if (j + 1 != attr_number)
                        cout << headTags[i].attributes[j] << ", ";
                    else
                        cout << headTags[i].attributes[j];
                }
                if (i + 1 != headTags.size())
                    cout << "], " << endl;
                else
                    cout << "]";
            }
        }
        cout << "]" << endl;
    } else
        cout << "]" << endl;
    
    cout << endl;
    return 0;
}
