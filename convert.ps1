## Purpose: Run this in a directory with a markdown file and pics folder and create a new folder with converted markdown and pics
## to be able to upload to a jekyll type blog (https://mademistakes.com/work/jekyll-themes/minimal-mistakes/). 
## It will also create a header. Basically this will make everything ready so that you can just copy over your pics/markdown blog
## post and upload with minor work.

## Created on 09/04/2023


param (

    ## Name of Markdown file to process
    [Parameter(Position=0, Mandatory=$true)]
    [string]$MarkdownFile,

    ## Output file name, this will be the directory name
    ## and the new markdown file name (with date added)
    [Parameter(Position=1, Mandatory=$true)]
    [string]$FileName,

    [Parameter(Position=2, Mandatory=$true)]
    [datetime]$TimeDate,

    ## Title of blog post
    [Parameter(Position=3, Mandatory=$true)]
    [string]$Title,

    ## Caption for blog post
    [Parameter(Position=4, Mandatory=$true)]
    [string]$Excerpt,

    ## Comma separted String
    [Parameter(Position=5, Mandatory=$true)]
    [string]$Categories,

    ## Comma separted String
    [Parameter(Position=6, Mandatory=$true)]
    [string]$Tags,

    ## Image File Path you want displayed on your blog post (optional)
    [Parameter(Position=7, Mandatory=$false)]
    [string]$Teaser

)

## Create dir structure, if already there, ignore
## _posts, assets/images --> If these already exist, leave them
## Create your assest Dir that will contain your images
## copy over and rename markdown to _posts
## go through your coped markdown and when you hit an image, copy over from image to assests (assets/images/{PROJECT_NAME})
## replace all markdown image links with your new path (assets/images/{PROJECT_NAME})
## Create a header for your new Markdown


## TODO:

# Define the file path
# $filePath = "C:\path\to\your\textfile.txt"

# Read the content of the file
# $content = Get-Content -Path $filePath -Raw

# Define the search pattern using a generic regular expression
# $pattern = '!\[\]\(.*/([^)]+)\)'

# Define the replacement pattern
# $replacement = '![](assests/images/$1)'

# Perform the replacement using regex
# $newContent = $content -replace $pattern, $replacement

# Write the modified content back to the file
# Set-Content -Path $filePath -Value $newContent

# Output a message to confirm completion
# Write-Host "String replacement completed in $filePath"


## Main

$postsDir = "$((Get-Location).Path)\_posts"
$assetsDir = "$((Get-Location).Path)\assets\images"
$baseName = $FileName
$postDate = $TimeDate.ToString("yyyy-MM-dd")
$imageDir = "$((Get-Location).Path)\assets\images\$baseName"


## Header Vars
$headerTitle = $Title
$headerExcerpt = $Excerpt
$headerCategories = ($Categories -split ',' | ForEach-Object { "    - $_" }) -join "`n"
$headerTags = ($Tags -split ',' | ForEach-Object { "    - $_" }) -join "`n"


## Check if dir exists, this will be checked from root of script, if not, then create dir

## _posts

if (Test-Path -Path $postsDir -PathType Container) {

    continue

}
else {

    New-Item -ItemType Directory -Path $postsDir -Force

}

## _assets
if (Test-Path -Path $assetsDir -PathType Container) {

    continue

}
else {

    New-Item -ItemType Directory -Path $assetsDir -Force

}


## Create your image dir (overwrite if it already exists)

    New-Item -ItemType Directory -Path $imageDir -Force


## Teaser

if ($Teaser) {
    
    $teaserFileName = $($Teaser -split "\\" | Select-Object -Last 1)
    $teaserMoveFilePath = "${imageDir}\${teaserFileName}"
    $teaserHomePage = $true

    if (Test-Path -Path $Teaser -PathType Leaf) {


        Move-Item -Path $Teaser -Destination $imageDir -Force
    
    }
    else {
    
        throw "<ERROR>Could Not find Teaser File!"
    
    }
    

} 
else {

    $teaserHomePage = $false

}


## Create you header

$header = "
---
title: `"${headerTitle}`"
date: ${postDate}
layout: single
excerpt: `"${headerExcerpt}`"
classes: wide
header:
  teaser: `"${teaserMoveFilePath}`"
  teaser_home_page: ${teaserHomePage} 
  #icon: `"/assets/images/HTB_Laboratory`"
categories:
${headerCategories}
tags:
${headerTags}
---
"


## ToDo
##- Create body that is the markdown with replaced Image files
##- Copy image files over to assets image folder location
##- Writeout new markdown file with header
##- Check to make sure script works!!!! 
