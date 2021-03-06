#' Get Posts from your LinkedIn Groups
#'
#' Currently this will retreive only the last 10 posts from each group
#'
#' @param token Authorization token 
#' @return Returns posts of groups you belong to
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroupPosts(in.auth)
#' }
#' @export


getGroupPosts <- function(token)
{
  membership_url <- "https://api.linkedin.com/v1/people/"
  membership_fields <- "/group-memberships:(group:(id,name),membership-state,show-group-logo-in-profile,allow-messages-from-members,email-digest-frequency,email-announcements-from-managers,email-for-every-new-post)"
  
  # group details:
  groups_url <- "https://api.linkedin.com/v1/groups/"
  post_fields <- "/posts:(creator:(first-name,last-name,headline),comments,id,title,summary,likes)"
  
  # This will return the posts of groups you're in
  url <- paste0(membership_url,"~",membership_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  
  if(as.numeric(xmlAttrs(q.content[["//group-memberships[@total]"]])[[1]])==0){
    print("You are not currently a member of any groups.")
  }
  else {
  gp.ids <- groupsToDF(q.content)$group_id
  gp.names <- groupsToDF(q.content)$group_name
  
  # This currently only retrieves the past 10 posts in each group
  # Would need to nest another loop to get more
  q.df <- data.frame()
  for(i in 1:length(gp.ids))
  {
    url <- paste0(groups_url, gp.ids[i], post_fields)  
    query <- GET(url, config(token=token))
    q.content <- content(query)
    temp.df <- groupPostToDF(q.content)
    q.df <- rbind(q.df, temp.df)
    }
  return(q.df)
  }
  # It's possible to extract info of poeple who commented and liked the posts
  # Perhaps build in additional featur
}