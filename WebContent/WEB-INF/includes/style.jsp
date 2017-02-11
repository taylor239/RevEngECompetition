<link rel="shortcut icon" href="img/tigress_favicon.png" />
<style>
*
{
    padding: 0px;
    margin: 0px;
	font-family:Arial, Helvetica, sans-serif;
}

html,body
{
	height:100%;
	max-width: 100%;
    overflow:hidden;
    overflow-x:hidden;
    overflow-y:hidden;
}

body
{
	overflow-y:scroll;
}

a
{
	//text-decoration: none;
	//border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	color:#0602e5;
	//box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	//padding:2px 2px;
	width:100%;
	//letter-spacing: .04em;
}

a:hover
{
	//font-weight:bold;
	text-shadow:0px 0px 1px #0006F0;
	//border: 2px #F00;
    //outline:0;
	//background: linear-gradient(#292929, #5261C7);
	color:#0602e5;
	//box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	//padding:2px 2px;
	cursor:pointer;
	//letter-spacing: 0em;
}

.boxedChar
{
	outline:1px solid black;
	//display:inline-block;
	//width:100%;
	//height:auto;
	//margin:5% 5% 2.5% 2.5%;
	//text-align:center;
	height: 1em;
}

.boxedChar:hover
{
	cursor:pointer;
}

a::after
{
	display: block;
	content: attr(title);
	font-weight: bold;
	height: 1px;
	color: transparent;
	overflow: hidden;
	visibility: hidden;
}

.image_link
{
	
}

.image_link:hover
{
	cursor:pointer;
}

#body_table
{
	width:100%;
	vertical-align: top;
	margin-bottom:0;
 	padding-bottom:0;
	margin-top:0;
	padding-top:0;
	outline:none;
	border:none;
	border-collapse:collapse;
}

#parent_div
{
	vertical-align: top;
	margin-bottom:0;
 	padding-bottom:0;
	margin-top:0;
	padding-top:0;
	outline:none;
	border:none;
	border-collapse:collapse;
}

#topnav
{
	text-align:center;
	align:center;
	vertical-align: top;
	//background: linear-gradient(#d782d7, #9E329E 25%, #B246B2 85%, #6c2a6c 95%, black);
	background-color:#0602e5;
	margin-bottom:0;
 	padding-bottom:0;
	margin-top:0;
	padding-top:0;
	outline:none;
	border:none;
}

#title_image
{
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#D3D3D3, #FFF);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #FFF;
	////border-radius:5px;
	padding:4px 4px !important;
}

.searchbox
{
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#FFF;
	////border-radius:5px;
	padding:8px 8px;
}

.submit
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #0602e5);
	background-color:#0602e5;
	color:#FFF;
	//box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px !important;
}

.button
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #0602e5);
	background-color:#0602e5;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px !important;
}

.submit:hover
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#292929, #5261C7);
	background-color:#111184;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	cursor:pointer;
	padding:8px 8px !important;
}

.button:hover
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#292929, #5261C7);
	background-color:#111184;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	cursor:pointer;
	padding:8px 8px !important;
}

input
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	background-color:#0602e5;
	color:#FFF;
	////border-radius:5px;
	padding:8px 8px;
}

textarea
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	background-color:#0602e5;
	color:#FFF;
	////border-radius:5px;
	padding:8px 8px;
}

input[type=submit]
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	background-color:#0602e5;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px;
}

button
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	background-color:#0602e5;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px;
}

input[type=submit]:hover
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#292929, #5261C7);
	background-color:#111184;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px;
	cursor:pointer;
}

input[type=button]
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#6F6FEA, #757575);
	background-color:#0602e5;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px;
}

input[type=button]:hover
{
	border: 2px #F00;
    outline:0;
	//background: linear-gradient(#292929, #5261C7);
	background-color:#111184;
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	////border-radius:5px;
	padding:8px 8px;
	cursor:pointer;
}

#login_table
{
	width:100%;
	margin-left:auto; 
    margin-right:auto;
}

#side_nav
{
	width:100%;
	transition:300ms linear;
}

#side_nav_row
{
	width:2.5%;
	transition:300ms linear;
	background: linear-gradient(to right, #FFEAEA 75%, white);
	vertical-align: top;
	height:50em;
	padding-right:.25%;
	padding-left:0;
}

#side_title
{
	transition:300ms linear;
}

#side_other_row
{
	width:2.5%;
	transition:300ms linear;
	background: linear-gradient(to right, #FFEAEA 75%, white);
	vertical-align: top;
	text-align:justify;
	text-align-last: right;
	padding-left:.25%;
	padding-right:0;
	height:50em;
}

#side_news
{
	width:100%;
	transition:300ms linear;
}

.side_button
{
	font-size:larger;
	visibility:hidden;
	opacity:0;
	width:100%;
	transition:300ms linear;
	border: 2px #F00;
    outline:0;
	color:#000;
	//border-radius:5px;
	padding:4px 4px;
	cursor:pointer;
	text-shadow:-1px -1px 0 #FFF, 1px -1px 0 #FFF, -1px 1px 0 #FFF, 1px 1px 0 #FFF;
	font-weight:bolder;
}

.side_button td:hover
{
	color:#FFF;
	text-shadow:-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
}

#side_news_title
{
	text-align:right;
}

.space
{
	transition:300ms linear;
	display:none;
}

.space hr
{
	color:linear-gradient(to left, #FFEAEA, #6F6FEA, #757575, #6F6FEA, #FFEAEA);
	background:linear-gradient(to left, #FFEAEA, #6F6FEA, #757575, #6F6FEA, #FFEAEA);
	height: .1em;
	border: 0;
	width:80%;
	text-align:center;
	align:center;
	margin:0 auto;
}

.visible_space hr
{
	color:linear-gradient(to left, #FFEAEA, #6F6FEA, #757575, #6F6FEA, #FFEAEA) !important;
	background:linear-gradient(to left, #FFEAEA, #6F6FEA, #757575, #6F6FEA, #FFEAEA) !important;
	height: .1em;
	border: 0;
	width:80%;
	text-align:center;
	align:center;
	padding-top:0;
	padding-bottom:0;
	margin:auto;
}

.side_news_item
{
	text-align:right;
	text-align-last: right;
	align:right;
	visibility:hidden;
	opacity:0;
	width:100%;
	transition:300ms linear;
	border: 2px #F00;
	outline:0;
	color:#000;
	//border-radius:5px;
	padding:4px 4px;
	text-shadow:-1px -1px 0 #FFF, 1px -1px 0 #FFF, -1px 1px 0 #FFF, 1px 1px 0 #FFF;
	cursor:pointer;
	font-size:larger;
}

.side_news_item td
{
	text-align:right;
	text-align-last: right;
	align:right;
	font-weight:bolder;
}

.side_news_item td:hover
{
	color:#FFF;
	text-shadow:-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
}

#top_nav_table
{
	align:center;
}

.top_button
{
	position:relative;
	font-size:x-large;
	align:center;
	text-align:center;
	width:20%;
	color:#FFF;
	////border-radius:5px;
	//padding:4px 4px !important;
	border:1px solid transparent;
	text-shadow:-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
	
}

.top_button:hover
{
	border: 1px solid #000;
}

#footer
{
	text-align:center;
	align:center;
	background: linear-gradient(to top, white 50%, #FFF 75%, #FFF 85%, #FFF 90%, #FFF 95%, #FFF);
	margin-bottom:0;
 	padding-bottom:0;
	margin-top:0;
	padding-top:1em;
	outline:none;
	border:none;
	border-collapse:collapse;
	color:#000;
	text-shadow:-1px -1px 0 #FFF, 1px -1px 0 #FFF, -1px 1px 0 #FFF, 1px 1px 0 #FFF;
	font-size:small;
}

#content
{
	width:100%;
	align:center;
	text-align:center;
	vertical-align:top;
	transition:300ms linear;
	padding:0px auto;
	margin:0px auto;
	//background: linear-gradient(to left, white 0%, white 25%, #E4A7A7 50%, white 75%, white 100%);
    background-attachment: fixed;
    background-position: center; 
}

#inner_content
{
	width:100%;
	align:center;
	text-align:center;
	vertical-align:top;
	transition:300ms linear;
	padding:0;
	//border: 1px solid #CCC;
	//background-color: #CCC;
	margin-left:auto; 
    margin-right:auto;
}

#inner_content td
{
	vertical-align:top;
}

#inner_content>tbody>tr>td
{
	//border: 1px solid #CCC;
	//background-color: #CCC;
	
	text-align:justify;
	margin:1em;
	padding:1em;
}

#inner_content>tbody>tr>td td
{
	background-color:transparent;
}

#institution_table
{
	width:100%;
	border: 1px solid #000;
}

#institution_title td
{
	background-color:#F4ECEC;
	font-weight:bolder;
	font-size:large;
}

.institution_row0
{
	width:100%;
}

.institution_row0 td
{
	background-color:#D8D5FF !important;
	background-color:rgba(220, 220, 255, .8) !important;
}

.institution_row0 td td
{
	background-color:transparent !important;
	background-color:transparent !important;
}

.institution_row1
{
	width:100%;
}

.institution_row1 td
{
	background-color:#F4ECEC;
}

.institution_row_title
{
	padding:.5em;
	//border-radius:5px;
	font-size:large;
	font-weight:bolder;
	padding-left:0;
	padding-right:0;
	width:100%;
}

.institution_info_row0
{
	//border-radius:5px;
	width:100%;
	height:100% !important;
	padding-left:0;
	padding-right:0;
	margin-left:0;
	margin-right:0;
	border: 1px solid #E7A9A9;
	background-color:#FFF !important;
}

.institution_info_row1
{
	//border-radius:5px;
	width:100%;
	height:100% !important;
	padding-left:0;
	padding-right:0;
	margin-left:0;
	margin-right:0;
	border: 1px solid #A0A6E0;
	background-color:#FFF !important;
}

.institution_info_row1 tr td
{
	padding-left:.5em;
	padding-right:.5em;
	width:100%;
	//border-radius:5px;
	background-color:#FFF !important;
}

.institution_info_row0 tr td
{
	padding-left:.5em;
	padding-right:.5em;
	width:100%;
	//border-radius:5px;
	background-color:#FFF !important;
}

#sort_list_select
{
	width:10em;
	text-decoration: none;
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
}

#sort_list_select option
{
	
	text-decoration: none;
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#000;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
}

.inner_content_table
{
	width:100%;
}

.inner_content_table > tbody > tr > td
{
	padding:.25em;
	width:100%;
	//border-radius:5px;
	background-color:#FFF !important;
	border: 1px solid #FFF;
}

#inner_content_title
{
	font-size:xx-large;
	font-weight:bolder;
	font-family:Georgia, "Times New Roman", Times, serif;
}

#inner_content_slogan
{
	font-size:x-large;
	font-family:Georgia, "Times New Roman", Times, serif;
}

.news_table
{
	width:100%;
}

.news_table > tbody > tr > td
{
	vertical-align:middle;
}

.news_table > tbody > tr > td > hr
{
	color:linear-gradient(to left, #FFEAEA, #C0C0C0, #FFEAEA);
	background:linear-gradient(to left, #FFEAEA, #C0C0C0, #FFEAEA);
	height: .1em;
	border: 0;
	width:100%;
	text-align:center;
	align:center;
	margin:0 auto;
}

.title_general td
{
	font-weight:bolder;
	font-size:large;
	vertical-align:bottom !important;
	padding-bottom:.5em;
}

.title_general td a
{
	font-weight:bolder;
	font-size:large;
	vertical-align:bottom !important;
	padding:.25em 1em !important;
	display:inline-block;
	text-align:center;
}

.title_general_text
{
	font-weight:bolder;
	font-size:large;
	vertical-align:middle !important;
	padding-bottom:.5em;
}

.top_padded td
{
	padding-top:.5em;
	text-align:center;
}

.news_item_table
{
	//border: 1px solid #D3A5A5;
	////border-radius:5px;
	padding-top:1em;
	padding-bottom:1em;
	padding-left:1em;
	padding-right:1em;
}

.break_table
{
	word-break:break-all;
	word-wrap:break-word;
}

.news_item_table_spaced
{
	border: 1px solid #D3A5A5;
	//border-radius:5px;
	padding-top:.75em;
	padding-bottom:.75em;
	padding-left:1em;
	padding-right:1em;
}

.news_item_table_spaced td
{
	padding-top:.25em;
	padding-bottom:.25em;
}

.normal_text
{
	font-size:medium !important;
	font-weight:normal !important;
}

#institution_select>td
{
	width:20%;
	text-align:center;
	text-decoration: none;
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
}

#institution_select>td:hover
{
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#292929, #5261C7);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
	cursor:pointer;
}

#institution_select_right>td
{
	width:100%;
	text-align:center;
	text-decoration: none;
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
}

#institution_select_right>td:hover
{
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#292929, #5261C7);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
	cursor:pointer;
}

#institution_select_left>td
{
	width:100%;
	text-align:center;
	text-decoration: none;
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#6F6FEA, #757575);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
}

#institution_select_left>td:hover
{
	border: 2px #F00;
    outline:0;
	background: linear-gradient(#292929, #5261C7);
	color:#FFF;
	box-shadow:inset 0px 1px 3px 0px #0006F0;
	//border-radius:5px;
	padding:2px 2px;
	cursor:pointer;
}

.profile_panel
{
	transition:300ms linear;
}

.item_selected
{
	border: 2px #F00 !important;
    outline:0 !important;
	//background: linear-gradient(#292929, #5261C7) !important;
	background-color:#111184;
	color:#FFF !important;
	box-shadow:inset 0px 1px 3px 0px #0006F0 !important;
	//border-radius:5px !important;
	padding:2px 2px !important;
	cursor:default !important;
}

.small
{
	font-size:smaller;
}

.cart_row_title td
{
	font-weight:bolder;
	text-align:center;
	font-size:large;
}

.cart_row_title
{
	
}

#cart_table > tbody > tr > td
{
	text-align:center;
	border: 20px #F00 !important;
	padding:2px 2px !important;
}

#cart_table > tbody > tr > td > hr
{
	color:linear-gradient(to left, #FFEAEA, #C0C0C0, #FFEAEA);
	background:linear-gradient(to left, #FFEAEA, #C0C0C0, #FFEAEA);
	height: .1em;
	border: 0;
	width:100%;
	text-align:center;
	align:center;
	margin:0 auto;
}

.bullet
{
	font-weight:bolder;
	text-align:right;
	vertical-align:middle !important;
}

.next_to_bullet
{
	text-align:justify;
}

#page_title_table_row
{
	background:#FFF !important;
	//border-radius:5px;
	width:60%;
}

.no_bottom_padding
{
	padding-bottom:0 !important;
}

.top_button ul
{
	z-index:100;
	white-space: nowrap;
	width:100%;
	display:none;
	position:absolute;
	//background: linear-gradient(#d782d7, #9E329E 25%, #B246B2 85%, #6c2a6c 95%, black);
	list-style-type: none;
	text-align:left;
	//overflow:hidden;
	//padding:.5em;
	top:100%;
	//outline:1px solid #000;
}

.top_button ul li
{
	//background: linear-gradient(#d782d7, #9E329E 25%, #B246B2 85%, #6c2a6c 95%, black);
	background-color:#0602e5;
	padding-left:.5em;
	padding-right:.5em;
	line-height:2em;
	//padding-bottom:.25em;
	//padding-top:.25em;
	//display:inline;
	font-size:large;
	font-weight:bold;
	outline:1px solid #000;
	border-right:1px solid #000;
	border-left:1px solid #000;
}

.top_button ul li:hover
{
	padding-left:.5em;
	padding-right:.5em;
	//padding-bottom:.25em;
	//padding-top:.25em;
	//display:inline;
	background-color: #400;
	//background: linear-gradient(#292929, #5261C7);
	background-color:#111184;
}

.top_button:hover > ul
{
	//background: linear-gradient(#d782d7, #9E329E 25%, #B246B2 85%, #6c2a6c 95%, black);
	background-color:#111184;
	white-space: nowrap;
	display:block;
	position:absolute;
	padding-top:.1%;
}

.top_button ul li ul
{
	z-index:200;
	white-space: nowrap;
	width:100%;
	height:auto;
	display:none;
	position:absolute;
	background-color: #4CAF50;
	list-style-type: none;
	text-align:left;
	//overflow:hidden;
	//padding:.5em;
	top:auto;
	left:100%;
}

.top_button ul li ul li
{
	padding-left:.5em;
	padding-right:.5em;
	//padding-bottom:.25em;
	//padding-top:.25em;
	display:block;
}

.top_button ul li:hover ul
{
	white-space: nowrap;
	display:inline;
	position:absolute;
}

</style>