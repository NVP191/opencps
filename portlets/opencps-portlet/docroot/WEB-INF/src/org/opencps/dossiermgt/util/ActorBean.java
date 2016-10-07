/**
 * OpenCPS is the open source Core Public Services software
 * Copyright (C) 2016-present OpenCPS community
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

package org.opencps.dossiermgt.util;

import org.opencps.util.PortletConstants;

import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.model.User;
import com.liferay.portal.service.UserLocalServiceUtil;


/**
 * @author khoavd
 *
 */
public class ActorBean {
	
	
    /**
     * 
     */
	public ActorBean(int actor, long userActionId) {

		this.setActor(actor);

		try {

			if (actor == 0) {
				this.setActorId(0);
				this.setActorName(PortletConstants.DOSSIER_STATUS_SYSTEM);
			}
			else {
				if (userActionId != 0) {
					User user = UserLocalServiceUtil.fetchUser(userActionId);

					this.setActorId(userActionId);
					this.setActorName(user.getFullName());
				}
				else {
					this.setActorId(0);
					this.setActorName(StringPool.BLANK);
				}

			}

		}
		catch (Exception e) {
			
		}

	}

    /**
     * @return the actor
     */
    public int getActor() {
    
    	return actor;
    }
	
    /**
     * @param actor the actor to set
     */
    public void setActor(int actor) {
    
    	this.actor = actor;
    }
	
    /**
     * @return the actorId
     */
    public long getActorId() {
    
    	return actorId;
    }
	
    /**
     * @param actorId the actorId to set
     */
    public void setActorId(long actorId) {
    
    	this.actorId = actorId;
    }
	
    /**
     * @return the actorName
     */
    public String getActorName() {
    
    	return actorName;
    }
	
    /**
     * @param actorName the actorName to set
     */
    public void setActorName(String actorName) {
    
    	this.actorName = actorName;
    }
	protected int actor;
	protected long actorId;
	protected String actorName;
}
