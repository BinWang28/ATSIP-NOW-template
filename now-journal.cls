%% $UFDate: 2017-05-25 19:42:19 +0200 -- Commit: a2a7e4e (origin/master, master) -- bibmacrokrise$
\def\fileversion{1.08h}
\def\filedate{2022/03/02}
%06.11.2014 moved articlebox up
%18.04.2015: moved biblatex to now-biblatex.sty. Added code to load a journal specific biblatex.sty
%28.04.2015 added \journaldoiprefix
%1.08: 01.05.2015 changed definition of articleDOI to handle numbers without prefix %reverted
%07.08.2015 added dot to "et al"
%26.03.2016 moved pdfauthor to hypersetup to avoid problems with non-glyph commands
% 27.06.2016 added \articletype code
% 25.05.2017 small change for cfr-author handling
% 25.05.2017 added \nowauthoraffilsep to separate authors and affil
% 03.02.2022 added code for OAStatement
% 03.02.2022 added code for biographies environment (loads enumitem)

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{now-journal}[\filedate\space Version \fileversion]

\providecommand\nowlistofjournals{example}
\def\now@example@fontsize{11pt}

% to allow the creation of an online and a print version:
\newif\ifnowprintmode
\providecommand\nowoutputmode{\nowprintmodefalse}
\nowoutputmode

%with \newnowjournal new journals shortcuts can be added
%the optional argument sets the font size of the journal:

\newcommand\newnowjournal[2][11pt]{%
  \g@addto@macro\nowlistofjournals{,#2}%
  \expandafter\def\csname now@#2@fontsize\endcsname{#1}%
  \expandafter\def\csname now@#2@biblatexstyle\endcsname{authoryear}%
  }


% add the current journals:
\newnowjournal{cfr}
\newnowjournal{dea}
\newnowjournal{irere}
\newnowjournal{jlfa}
\newnowjournal{jmb}
\newnowjournal[10pt]{jws}%fontsize will be change again in the sty
\newnowjournal{sbe}
\newnowjournal{rbe}
\newnowjournal[10pt]{qjps}
\newnowjournal[12pt]{jws}

% Input the now-production.cfg which can overwrite settings
% at first the parent folder is search then the texmf tree
% the file can change \nowproductionoptions
\InputIfFileExists{../now-production.cfg}
  {\ClassInfo{now-journal}{../now-production.cfg used}}
  {\InputIfFileExists{now-production.cfg}
        {\ClassInfo{now-journal}{../now-production.cfg used}}
        {\ClassInfo{now-journal}{no now-production.cfg found}}}

%default for \nowproductionoptions
\providecommand\nowproductionoptions{}

% in this cfg-file new journals can be declared
\InputIfFileExists{now-listofjournals.cfg}{}{}

%etoolbox is needed to avoid clashes with hyperref.
\IfFileExists{etoolbox.sty}{%
 \RequirePackage{etoolbox}%
 }{}{}

 \ifcsname AfterEndPreamble\endcsname
 \else
 \let\AfterEndPreamble\AtBeginDocument
 \fi

%Some \if for the options:
\newif\if@nowwrapper
\@nowwrapperfalse

\newif\if@nownobib
\@nownobibfalse

\newif\if@nowbiber
\@nowbiberfalse

\newif\if@nowmicrotype
\@nowmicrotypefalse

\newif\if@nowproductionconfig %this switch is only for debugging/forcing articles to ignore the cfg
\@nowproductionconfigtrue

\newif\if@nowonlineversion
\@nowonlineversiontrue

%Options
\DeclareOption{wrapper}{\@nowwrappertrue}%
\DeclareOption{nobib}{\@nownobibtrue}
\DeclareOption{biber}{\@nownobibfalse\@nowbibertrue}
\DeclareOption{noconfig}{\@nowproductionconfigfalse}
\DeclareOption{microtype}{\@nowmicrotypetrue}

%every journal shortcut creates an option:
\@for\now@temp:=\nowlistofjournals\do
 {\edef\next{\noexpand\DeclareOption{\now@temp}{\noexpand\def\noexpand\now@journalkey{\now@temp}}}%
  \next}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ExecuteOptions{example}
\ProcessOptions\relax

%an existing cfg-file is loaded to setup more special
%things of a journal.

\InputIfFileExists{../now-\now@journalkey-init.cfg}%
  {\ClassInfo{now-journal}{../now-\now@journalkey-init.cfg used}}%
  {\InputIfFileExists{now-\now@journalkey-init.cfg}%
        {\ClassInfo{now-journal}{../now-\now@journalkey-init.cfg used}}%
        {\ClassInfo{now-journal}{no now-\now@journalkey-init.cfg found}}}%


\if@nowproductionconfig  %this switch is only for debugging/forcing articles to ignore the cfg
 \nowproductionoptions
\fi


%Load class
\RequirePackage{fix-cm}
\LoadClass[\csname now@\now@journalkey @fontsize\endcsname,letterpaper,onecolumn,twoside]{article}


%Fonts
%TO-DO: Tests for luatex, xetex ?
\RequirePackage[T1]{fontenc}
\RequirePackage{textcomp}
\RequirePackage{eurosym}
\let\texteuro\euro
\if@nowmicrotype
\IfFileExists{microtype.sty}
 {\AtBeginDocument{\RequirePackage{microtype}}}
 {\typeout{microtype not found}}
\fi
%Tools -- packages needed by the class
\RequirePackage{ifthen}
\RequirePackage{lastpage}
\RequirePackage{refcount}
\setrefcountdefault{1}
\RequirePackage{keyval}
\RequirePackage{xr}
\RequirePackage[bottom,multiple]{footmisc}
\RequirePackage{trimspaces}
\RequirePackage{array}
\IfFileExists{needspace.sty}{\RequirePackage{needspace}}{\typeout{needspace not found.}}
\RequirePackage{enumitem}
%Useful user packages
\IfFileExists
 {csquotes.sty}
 {\RequirePackage{csquotes}}
 {\typeout{csquotes not found. Faking enquote to produce normal quotes}}
\providecommand\enquote[1]{``#1''}

\RequirePackage{graphicx}
\RequirePackage[figuresright]{rotating}
\RequirePackage{dcolumn}
\newcolumntype{d}[1]{D{.}{.}{#1}}

\RequirePackage{amsmath,amsthm}

\IfFileExists
 {booktabs.sty}
 {\RequirePackage{booktabs}}
 {\typeout{booktabs not found}}

%some registers
\newcounter{now@tempcnt}
\newtoks\now@temptoks
\newwrite\now@write
\newlength\now@templen

%fonts
\newcommand\now@font@section                 {\normalfont\normalsize\sffamily\bfseries\boldmath}
\newcommand\now@font@frontmattersection      {\now@font@section\rmfamily}
\newcommand\now@font@subsection              {\normalfont\small\bfseries\itshape\boldmath}
\newcommand\now@font@frontmattersubsection   {\now@font@subsection\upshape}
\newcommand\now@font@subsubsection{\normalfont\small\itshape}
\newcommand\now@font@paragraph    {\normalfont\normalsize\bfseries\boldmath}
\newcommand\now@font@subparagraph {\normalfont\normalsize\itshape}
\newcommand\now@font@caption      {\normalfont\footnotesize}
\newcommand\now@font@table        {\normalfont\footnotesize}
\newcommand\now@font@articledata  {\normalfont\footnotesize}
\newcommand\now@font@footer       {\normalfont\small}
\newcommand\now@font@header       {\normalfont\footnotesize\itshape}
\newcommand\now@font@abstract     {\normalfont\normalsize}
\newcommand\now@font@keywordstitle{\normalfont\normalsize\itshape}
\newcommand\now@font@keywordstext {\normalfont\normalsize}
\newcommand\now@font@authors      {\normalfont\normalsize}
\newcommand\now@font@affil        {\normalfont\normalsize\itshape}
\newcommand\now@font@title        {\normalfont\LARGE\bfseries\selectfont}
\newcommand\now@font@articletypetitle{\normalfont\Large\bfseries\selectfont}
\newcommand\now@font@subtitle     {\normalfont\small\bfseries\selectfont}
\newcommand\now@font@editortext   {\normalfont\small\selectfont}
\newcommand\now@font@infotext     {\normalfont\fontsize{9}{12}\selectfont}
\newcommand\now@font@tablenote    {\normalfont\scriptsize}
\newcommand\now@font@tablefigdesc {\normalfont\footnotesize}

\DeclareRobustCommand\now@font@authorcontents{\normalfont\normalsize\itshape}

%Page layout
\normalsize\selectfont
\usepackage[paperwidth=156mm,
            paperheight=234mm,
            hmarginratio=1:1,
            vmarginratio=1:1,
            textwidth=28pc,
            %headheight=8pt,
            headsep=17pt,
            footskip=22pt,
            textheight=180mm,
            heightrounded]{geometry}

\PassOptionsToPackage{x11namees,svgnames,table}{xcolor}
\IfFileExists{xcolor.sty}
 {\RequirePackage{xcolor}}
 {\RequirePackage{color}
  \RequirePackage{colortbl}}


%sectioning
\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {-24pt \@plus -6pt \@minus -3pt}%
                                   {12pt}%
                                   {\now@font@section}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                   {-18pt \@plus -6pt \@minus -3pt}%
                                   {6pt}%
                                    {\now@font@subsection}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                   {-22pt \@plus -2pt \@minus -2pt}%
                                   {6pt}%
                                    {\now@font@subsubsection}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                   {-12pt \@plus -2pt \@minus -2pt}%
                                    {.001pt}%
                                    {\now@font@paragraph}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\z@}%UF changed \parindent to \z@
                                    {3.25ex \@plus1ex \@minus .2ex}%
                                     {-1em}%
                                     {\now@font@subparagraph}}

%compact itemize in the journaldata
\newcommand\nowcompactlist{%
 \itemsep=0pt \@topsep=0.5\@topsep \parskip=0pt}

%bibliography
\providecommand\nowbiblatexbackend{biber}
\if@nownobib
 \expandafter\@firstoftwo
\else
 \expandafter\@secondoftwo
\fi
  {\providecommand\printbibliography[1][]{}}
  {\if@nowbiber
    \expandafter\@firstoftwo
   \else
    \expandafter\@secondoftwo
   \fi
   {\IfFileExists{now-\now@journalkey-biblatex.sty}{\RequirePackage{now-\now@journalkey-biblatex}}{\RequirePackage{now-sip-biblatex}}}
   {\RequirePackage{natbib}
    \bibliographystyle{nowsort}
    \def\now@addbib@resource{}%
    \def\now@bibcomma{}
    \def\addbibresource#1{%
     \filename@parse{#1}%
     \ifx\filename@ext\relax
      \PackageWarning{now-journal}{You forgot the extension "bib"}{}
     \else
      \edef\now@tempa{\now@bibcomma\filename@area\filename@base}%
      \gdef\now@bibcomma{,}%
      \expandafter\g@addto@macro\expandafter\now@addbib@resource\expandafter{\now@tempa}%
     \fi}
    \newcommand\printbibliography[1][]{%
     \ifx\now@addbib@resource\@empty
      %\PackageError{now-journal}{No bib-file declared}{}
     \else
      \expandafter\bibliography\expandafter{\now@addbib@resource}%
     \fi
  }}}



%Data commands

% \now@setupdatacommands defines command
% of type \xyx{#1} = \def\now@xyx{#1}
\newcommand\now@setupdatacommands[1]{%
 \@for\now@tempcs:=#1\do
  {\expandafter\newcommand\csname now@\now@tempcs\endcsname{}%
   \expandafter\def\csname now@\now@tempcs\endcsname{}%
   \edef\next{%
   \noexpand\newcommand\csname \now@tempcs\endcsname[1]{%
   \noexpand\expandafter\noexpand\gdef\noexpand\csname now@\now@tempcs\endcsname{####1}}}%
   \next
  }}

%% data set in articles. Naming is rather loose.

%2 types of keywords: JEL and main:
\newcommand\now@keywords@main{}
\let\now@keywords@main\@empty
\newcommand\now@keywords@main@title{Keywords}

\expandafter\newcommand\csname now@keywords@JEL\endcsname{}
\let\now@keywords@JEL\@empty
\newcommand\now@keywords@JEL@title{JEL Codes}

\newlength\now@len@keywordindent

\newcommand\keywords[2][main]{%
 \ifcsname now@keywords@#1\endcsname
  \expandafter\def\csname now@keywords@#1\endcsname{#2}%
  \settowidth\now@templen{{\now@font@keywordstitle\csname now@keywords@#1@title\endcsname:~}}%
  \ifdim\now@templen>\now@len@keywordindent
   \now@len@keywordindent=\now@templen
  \fi
 \else
  \ClassError{now-journal}{Keyword type #1 unknown}
 \fi}

\newcommand\now@keyword@sep{,\space}

\newcommand\now@print@keywords[1]{%
 \unskip
 \def\now@temp@startpunct{}%
 \@for\now@temp:=#1 \do{%
  \now@temp@startpunct{}\now@temp
  \let\now@temp@startpunct\now@keyword@sep
  }}


% title need special treatment as it can be different in various locations (bib, header, toc, title)
\define@key{nowtitle}{bib}{\def\now@articlebibtitle{#1}}
\define@key{nowtitle}{header}{\def\now@articleheadertitle{#1}}
\define@key{nowtitle}{title}{\def\now@articletitle{#1}}
\define@key{nowtitle}{toc}{\def\now@articletoctitle{#1}}

 \newcommand\now@articletitle{}
 \newcommand\now@articlebibtitle{}
 \newcommand\now@articleheadertitle{}
 \newcommand\now@articletoctitle{}


\renewcommand\title[2][]{%
 \setkeys{nowtitle}{bib={#2},header={#2},title={#2},toc={#2}}
 \setkeys{nowtitle}{#1}}

\newcommand\now@articletypetitle{}
\newcommand\articletype[1]{\def\now@articletypetitle{#1}}


% subtitles are not predefined and currently not used. But perhaps need later.

\newcommand\articlesubtitle[1]{\gdef\now@articlesubtitle{#1}}
\let\subtitle\articlesubtitle

\def\now@titlefootnote{}
\newcommand\titlefootnote[1]{\def\now@titlefootnote{#1}}

%OAstatements
\newcommand\OAstatement[2][20pt]{\gdef\now@articleoastatement{#2}\gdef\now@articleoastatementskip{#1}}
\OAstatement[0pt]{}

%authors need very special treatment.
%There three places where author names (lists) are used: title (fullname), header (last), bib-file
%authors can have three name parts: First, Junior, Last (in bib-Order).

\def\now@splitauthor#1,#2,#3,#4\@nil{%
 \def\now@tempa{!}%
 \def\now@firstname{}\def\now@juniorpart{}\def\now@lastname{}%
 \def\now@tempfirstarg{#1}\def\now@tempsecondarg{#2}\def\now@tempthirdarg{#3}%
 \ifx\now@tempthirdarg\now@tempa
   \ifx\now@tempsecondarg\now@tempa
    \typeout{First name missing}%
    \def\now@lastname{#1}%
   \else
    \def\now@lastname{#1}%
    \def\now@firstname{#2}%
   \fi
 \else
   \def\now@lastname{#1}%
   \def\now@juniorpart{#2}%
   \def\now@firstname{#3}%
 \fi%
   \trim@spaces@in\now@lastname
   \trim@spaces@in\now@juniorpart
   \trim@spaces@in\now@firstname}

\newcounter{now@author@cnt}
\newcounter{now@affil@cnt}
\newcounter{now@affilmax@cnt}
\setcounter{now@affil@cnt}{0}

\newcommand\now@authorlist@bibsep{}
\newcommand\now@authorlist@bib{}

\renewcommand\author[2][\the\numexpr\c@now@affil@cnt+1]{%
 \stepcounter{now@author@cnt}%
 \now@splitauthor#2,!,!,\@nil%
 \edef\next{\noexpand\g@addto@macro\noexpand\now@authorlist@bib{%
        \now@authorlist@bibsep\unexpanded{#2}}}\next
 \def\now@authorlist@bibsep{ and }%
 \expandafter\edef\csname now@authorlastname@\the\c@now@author@cnt\endcsname{\unexpanded\expandafter{\now@lastname}}%
 \expandafter\edef\csname now@authorfullname@\the\c@now@author@cnt\endcsname%
           {\unexpanded\expandafter{\now@firstname~}\unexpanded\expandafter{\now@lastname}%
             \ifx\now@juniorpart\@empty
             \else,\noexpand~\unexpanded\expandafter{\now@juniorpart}%
             \fi}%
 \expandafter\edef\csname now@authoraffilmark@\the\c@now@author@cnt\endcsname{#1}%
 \now@store@authorlist@header
 \now@store@authorlist@toc
}

\newcommand\affil[2][\the\c@now@affil@cnt]{%
 \stepcounter{now@affil@cnt}%
 \c@now@affilmax@cnt=\numexpr\c@now@author@cnt\relax
 \expandafter\def\csname now@affil@\the\c@now@affil@cnt\endcsname{#2}%
 \expandafter\edef\csname now@affilmark@\the\c@now@affil@cnt\endcsname{#1}%
 }

%Commands to create authorlists
% 1. a list for the header: Lastnames, if > 2 authors: et al,
\newcommand\now@authorlist@header{}%
\newcommand\now@store@authorlist@header{%
 \ifcase\c@now@author@cnt
 \or
 \edef\now@authorlist@header{\unexpanded\expandafter\expandafter\expandafter{\csname now@authorlastname@1\endcsname}}%
 \or
 \edef\now@authorlist@header{\unexpanded\expandafter\expandafter\expandafter{\csname now@authorlastname@1\endcsname} and
                             \unexpanded\expandafter\expandafter\expandafter{\csname now@authorlastname@2\endcsname}}%
 \else
 \edef\now@authorlist@header{\unexpanded\expandafter\expandafter\expandafter{\csname now@authorlastname@1\endcsname} et al.}%
 \fi}%

% 1. a list for the wrapper  toc.
\newcommand*\now@authorlist@toc{}

\newcommand\now@store@authorlist@toc{%
  \edef\now@authorlist@toc{\unexpanded\expandafter\expandafter\expandafter{\csname now@authorfullname@1\endcsname}}%
  \ifnum\c@now@author@cnt=1\relax
  \else
  \c@now@tempcnt=2\relax
    \whiledo{\c@now@tempcnt<\c@now@author@cnt}
      {\edef\now@authorlist@toc%
         {\unexpanded\expandafter{\now@authorlist@toc,}
          \unexpanded\expandafter\expandafter\expandafter{\csname now@authorfullname@\the\c@now@tempcnt\endcsname}}%
       \stepcounter{now@tempcnt}%
      }%
      \edef\now@authorlist@toc%
       {\unexpanded\expandafter{\now@authorlist@toc} and
        \unexpanded\expandafter\expandafter\expandafter{\csname now@authorfullname@\the\c@now@author@cnt\endcsname}}%
  \fi
}


\define@key{nowauthorlist}{bib}{\def\now@authorlist@bib{#1}}
\define@key{nowauthorlist}{header}{\def\now@authorlist@header{#1}}
\define@key{nowauthorlist}{toc}{\def\now@authorlist@toc{#1}}

\newcommand\authorlists[1]{\setkeys{nowauthorlist}{#1}}


%Data per issues. Name starts always with issue

 \now@setupdatacommands{issuecopyrightyear,%
                        issuevolumenumber,%
                        issuevolumeyear,%
                        issuestartpage,%
                        issuenumber}

\issuecopyrightyear{2023}
\issuevolumenumber{03}
\issuenumber{1}
\issuevolumeyear{2023}
\issuestartpage{1}

%Data per journal. Name starts with journal.
 \now@setupdatacommands{journaltitle,%
                        journalshorttitle,%
                        journalurl,%
                        journalissnprint,%
                        journalissnonline,%
                        journalaimsandscope,%
                        journalsubmission,%
                        journalabstractedin,%
                        journaltotalissuenumber,%
                        journaldoiprefix,%
                        }

\journaltotalissuenumber{4}

\newcommand\journalname{\now@journaltitle}
\newcommand\journalshortname{\now@journalshorttitle}

%Input the data. The issuedata is generated by the wrapper. It will, if necessary overwrite the journalkey
\if@nowwrapper
\else
 \InputIfFileExists{../current-issuedata}{}{}%
\fi
%Search first the wrapper folder, then the texmf+current dir.
 \IfFileExists{../\now@journalkey-journaldata.tex}
  {\input{../\now@journalkey-journaldata.tex}}
  {\IfFileExists{\now@journalkey-journaldata.tex}
   {\input{\now@journalkey-journaldata}}
   {\typeout{Journal data for \now@journalkey\space not found}
    \typeout{loading the example data instead}%
    \input{example-journaldata}}}

%write the data to a bib-file + a toc-file
\newcommand\nowtocnewline{}
\if@nowwrapper\else
\AtEndDocument{%
 \immediate\openout\now@write =\jobname-bibinfo.bib\relax
 \immediate\write\now@write{@article\csname @charlb\endcsname \jobname,}
 \immediate\write\now@write{title={\unexpanded\expandafter\expandafter\expandafter{\now@articlebibtitle}},}
 \ifcsname now@articlesubtitle\endcsname
 \immediate\write\now@write{subtitle={\csname now@articlesubtitle\endcsname},}
 \fi
 \immediate\write\now@write{author={\unexpanded\expandafter{\now@authorlist@bib}},}
 \immediate\write\now@write{journaltitle={\csname now@journaltitle\endcsname},}
 \immediate\write\now@write{year={\now@issuevolumeyear},}%
 \immediate\write\now@write{pages= {\getpagerefnumber{FirstPage}-\getpagerefnumber{LastPage}},}
 \ifx\now@journalissnprint\@empty
 \immediate\write\now@write{issn={\csname now@journalissnonline\endcsname},}
 \else
 \immediate\write\now@write{issn={\csname now@journalissnprint\endcsname},}
 \fi
 \ifx\now@articleDOI\now@defaulttextcontent\else
  \immediate\write\now@write{DOI={\now@articleDOI},}
 \fi
 \ifx\now@keywords@main\@empty\else
 \immediate\write\now@write{NOWkeywords={\now@keywords@main},}
 \fi
 \ifx\now@keywords@JEL\@empty\else
 \immediate\write\now@write{JELkeywords={\now@keywords@JEL}}
 \fi
 \immediate\write\now@write{\csname @charrb\endcsname}%
 \immediate\closeout\now@write
 \immediate\openout\now@write=\jobname-wrapper.toc\relax
 \ifx\now@authorlist@toc\@empty
  \immediate\write\now@write{%
  \noexpand\addtocontents{toc}{%
  \noexpand\protect\noexpand\contentsline{section}{%
   \unexpanded\expandafter{\now@articletoctitle}}%
  {\getpagerefnumber{FirstPage}--\getpagerefnumber{LastPage}}{}}}%
 \else
 \immediate\write\now@write{%
  \noexpand\addtocontents{toc}{%
  \noexpand\protect\noexpand\contentsline{section}{%
   \unexpanded\expandafter{\now@articletoctitle\nowtocnewline}{\unexpanded{\csname now@font@authorcontents\endcsname}\unexpanded\expandafter{\now@authorlist@toc}}}
  {\getpagerefnumber{FirstPage}--\getpagerefnumber{LastPage}}{}}}%
 \fi
 \immediate\closeout\now@write
 }
\fi


%get + set pagenumber
\@ifundefined{nowpredecessor}
 {\setcounter{page}{\now@issuestartpage}}
 {\externaldocument[page-]{\nowpredecessor}%
  \setcounter{page}{\getpagerefnumber{page-LastPage}}%
  \stepcounter{page}%
  \ifodd\c@page\else\stepcounter{page}\fi}

\AfterEndPreamble{\label{FirstPage}}

%footnotes
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width\columnwidth
  \kern2.6\p@}


%abstract
\newcommand\now@abtractendhook{}

\renewenvironment{abstract}
 {\now@font@abstract\clubpenalty=10000%
  \begin{list}{}{\rightmargin\leftmargin}%
          \item\relax
 \hspace*{-\leftmargin}\noindent\makebox[\linewidth][l]{\rule{\textwidth}{0.5pt}}\par\vspace{\medskipamount}\nobreak
          ABSTRACT\par\@afterheading}
 {\par\nobreak\hspace*{-\leftmargin}\makebox[\linewidth][l]{\rule{\textwidth}{0.5pt}}\end{list}
  \ifx\now@keywords@main\@empty
  \else
  \begingroup\now@font@keywordstext\noindent
    \@hangfrom{\makebox[\now@len@keywordindent][l]{\now@font@keywordstitle\now@keywords@main@title:~}}%
    \now@print@keywords{\now@keywords@main}\par\endgroup
  \addvspace{\medskipamount}%
  \fi
  \ifx\now@keywords@JEL\@empty
  \else
  \begingroup\now@font@keywordstext\noindent
   \@hangfrom{\makebox[\now@len@keywordindent][l]{\now@font@keywordstitle\now@keywords@JEL@title:~}}\now@print@keywords{\now@keywords@JEL}\par\endgroup
  \fi
  \addvspace{\medskipamount}\now@abtractendhook}

%maketitle
\newcommand\now@printaffilmark[1]{%#1=author number
  \textsuperscript{\csname now@authoraffilmark@#1\endcsname}%
 }



\DeclareRobustCommand\now@printauthors{%
 \ifnum\c@now@author@cnt=0\relax
 \else
   \csname now@authorfullname@1\endcsname
      \now@printaffilmark{1}%
   \ifnum\c@now@author@cnt=1\relax
   \else
   \c@now@tempcnt=2\relax
    \whiledo{\c@now@tempcnt<\c@now@author@cnt}
      {,\space\csname now@authorfullname@\the\c@now@tempcnt\endcsname
       \now@printaffilmark{\the\c@now@tempcnt}%
       \stepcounter{now@tempcnt}%
      }
    and \csname now@authorfullname@\the\c@now@author@cnt\endcsname
        \now@printaffilmark{\the\c@now@author@cnt}%
   \fi
   \ifcsname now@creditlinetext\endcsname
     \footnote{\now@creditlinetext}%
   \fi
\fi}



\newcommand\now@printaffils{%
 \begingroup\now@font@affil
  \ifnum\c@now@affil@cnt > 0
  \c@now@tempcnt=0\relax
    \whiledo{\c@now@tempcnt<\c@now@affil@cnt}
      {\par
       \stepcounter{now@tempcnt}%
        \textsuperscript{\upshape\csname now@affilmark@\the\c@now@tempcnt\endcsname}%
        \csname now@affil@\the\c@now@tempcnt\endcsname
      }%
  \fi
 \endgroup
  }


\newcommand\creditline[2][*]{%
 \def\now@creditlinemark{#1}%
 \def\now@creditlinetext{#2}}

\newsavebox\now@article@databox{}
\sbox\now@article@databox{}
\newcommand\now@article@databox@wd{\dimexpr\textwidth\relax}
\newcommand\articledatabox[1]{%
 \AtBeginDocument{%
 \sbox\now@article@databox{\parbox[b]{\now@article@databox@wd}
  {\now@font@articledata\rule{\now@article@databox@wd}{0.5pt}\par #1}}}}

\newcommand\now@defaulttextcontent{00000001}

\newcommand\articleDOI[1]{\def\now@articleDOI{#1}}

%\renewcommand\articleDOI[1]{%
% \now@split@DOI#1//\@nil}

\newcommand\now@split@DOI{}
\def\now@split@DOI#1/#2/#3\@nil{%call as \now@split@DOI<arg>//\@nil
 \def\@tempa{#3}%
 \ifx\@tempa\@empty %kein slash im Argument
   \ifx\now@journaldoiprefix\@empty
    \ClassWarning{now-journal}{Journal DOI prefix missing!}%
    \def\now@articleDOI{XX.XXX/#1}%
   \else
    \def\now@articleDOI{\now@journaldoiprefix/#1}%
   \fi
 \else
  \def\now@articleDOI{#1/#2}%
 \fi}


\let\now@articleDOI\now@defaulttextcontent

\newcommand\articlecopyrightholder[1]{\def\now@articlecopyrightholder{#1}}
\let\now@articlecopyrightholder\now@defaulttextcontent

\AtBeginDocument{%
\sbox\now@article@databox{\parbox[b]{\now@article@databox@wd}
  {\now@font@articledata\rule{\now@article@databox@wd}{0.5pt}\par
   ISSN \ifx\now@journalissnprint\@empty \now@journalissnonline\else\now@journalissnprint\fi; DOI \now@articleDOI\\
   \copyright\now@issuecopyrightyear~\now@articlecopyrightholder}}}


\newcommand\disclaimer[1]{\def\now@disclaimer{#1}}

\newcommand\nowauthoraffilsep{\medskip}

\renewcommand\maketitle{%
 \begingroup
 \setfnsymbol{wiley}%
 \renewcommand\thefootnote{\fnsymbol{footnote}}%
 \begingroup
 \raggedright
 \thispagestyle{firstpage}%
 \vspace*{\now@articleoastatementskip}%
 \enlargethispage{\dimexpr-\ht\now@article@databox-\footskip+\baselineskip}%06.11.2014
 {\now@font@articletypetitle \now@articletypetitle\par}
 \now@font@title{%
  \def\footnote{\ClassError{now-journal.cls}{Don't use \string\footnote\space in the title!^^J
                Use \string\titlefootnote\space after \string\title\space instead}{}{}}\now@articletitle}%
 \ifx\now@titlefootnote\@empty\else\footnote{\now@titlefootnote}\fi\par\medskip
 \now@font@authors\now@printauthors\par\nowauthoraffilsep
 \now@printaffils\par
 \endgroup
 \ifcsname now@disclaimer\endcsname\medskip\begingroup\noindent\small\textbf{Disclaimer:~}\ignorespaces\now@disclaimer\par\endgroup\fi
 \endgroup\setcounter{footnote}{0}
 }

\providecommand\nowsetfootnotespace{}
\newdimen\now@dim@footinsheight
\now@dim@footinsheight=\the\dimen\footins

\IfFileExists{atbegshi.sty}{%
 \RequirePackage{atbegshi}
 \renewcommand\nowsetfootnotespace[1]{%
  \begingroup\footnotesize
  \global\dimen\footins=##1\baselineskip\relax
  \endgroup
  \AtBeginShipout{\global\dimen\footins =\now@dim@footinsheight}%
  }}
  {\renewcommand\nowsetfootnotespace[1]{\PackageWarning{now-journal}{atbegshi not found, footnote space can not be changed}{}{}}}{}


%header and footer.

\RequirePackage{fancyhdr}
\pagestyle{fancy}
\renewcommand\headrulewidth{0pt}
\fancyhf{}
\fancyhead[LE,RO]{\now@font@header\thepage}
\fancyhead[LO]{\now@font@header\now@articleheadertitle}
\fancyhead[RE]{\now@font@header\now@authorlist@header}

\fancypagestyle{firstpage}{%
 \fancyhf{}%
 \lhead{%
   \raisebox{0pt}[0pt][0pt]{%
    \parbox[t]{\textwidth}{%
      \now@font@header\textit{\now@journaltitle}, \now@issuevolumeyear, \now@issuevolumenumber: \pageref{FirstPage}--\pageref{LastPage}\par
      \now@articleoastatement}}}
 \lfoot{\raisebox{\footskip}[0pt][0pt]{\usebox\now@article@databox}}}%06.11.2014

%load wrapper sty:

\if@nowwrapper
 \IfFileExists{now-wrapper.sty}
 {\RequirePackage{now-wrapper}}
 {\ClassError{now-journal}{now-wrapper.sty not found}{}}
\else
 \AtBeginDocument{%
  \RequirePackage[%
   colorlinks    = true,
   allcolors     = blue,
   plainpages    = false,
   pdfpagelabels = true,
  ]{hyperref}
 \hypersetup{pdfauthor={\now@authorlist@toc},}
  \ifnowprintmode
   \expandafter\@firstofone
  \fi
  {\hypersetup{hidelinks}}%\fi
  }
 \AfterEndPreamble{\maketitle}
\fi


%captions
\IfFileExists{caption.sty}
 {\RequirePackage{caption}
  \DeclareCaptionFont{now}{\now@font@caption}
  \captionsetup[table]{position=above}
  \captionsetup{font=now}
 }
 {\ClassWarning{now-journal}{Couldn't load caption.sty, captions are not set up}{}{}}


%theorem-environments: copied from qjps.cls
\newtheorem{theorem}{Theorem}
\newtheorem{corollary}{Corollary}
\newtheorem{assumption}{Assumption}
\newtheorem{definition}{Definition}
\newtheorem{proposition}{Proposition}
\newtheorem{lemma}{Lemma}
\newtheorem{conjecture}{Conjecture}


\providecommand\Note[1]{\begingroup\par\smallskip\now@font@tablenote\textbf{Note: }#1\par\endgroup}
\providecommand\Source[1]{}
\providecommand\Description[1]{}
\providecommand\Interpretation[1]{}

% Biographies. This is a simple description list with no margin
\newenvironment{biographies}
 {\begin{description}[leftmargin=0pt]}
 {\end{description}}

\IfFileExists{now-\now@journalkey.sty}{\RequirePackage{now-\now@journalkey}}{}{}

\nowsetfootnotespace{3}
\endinput
