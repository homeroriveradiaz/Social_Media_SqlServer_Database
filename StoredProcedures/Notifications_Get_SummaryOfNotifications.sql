USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_GetHighLevelNotifications]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Notifications_Get_SummaryOfNotifications](
	@UserID BIGINT
)
AS


SELECT ISNULL((
	SELECT CASE --NOTE: TYPE  5 (POSTING DELETED) BELONGS TO THE SAME PLACE AS TYPE 4 (PINBOARD). HENCE THE CASE STATEMENT, IN ORDER TO MATCH THEM
			WHEN NT.NotificationTypeID = 5 THEN 4
			ELSE NT.NotificationTypeID
		END AS notificationTypeId
		, COUNT(N.NotificationTypeID) AS countOfNotifications
	FROM dbo.Notifications_ForUserInterface_Types AS NT WITH(NOLOCK)
	INNER JOIN dbo.Notifications_ForUserInterface AS N WITH(NOLOCK) ON N.UserID = @UserID AND N.NotificationTypeID = NT.NotificationTypeID
	GROUP BY CASE WHEN NT.NotificationTypeID = 5 THEN 4
			ELSE NT.NotificationTypeID
		END
	FOR JSON PATH, ROOT('notifications')
), '{"notifications":[]}') AS jsonString;


GO


