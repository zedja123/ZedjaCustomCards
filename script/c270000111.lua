--
--Wiccanthrope Vilecoil
--scripted by Zedja
local s,id=GetID()
local SET_WICCANTHROPE=0xe01
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters, including a "Wiccanthrope" monster
	Xyz.AddProcedure(c,nil,4,2,nil,nil,nil,nil,false,s.xyzcheck)
	--If this card is Xyz Summoned: You can banish the top card of each player's Deck face-up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--(Quick Effect): You can detach 1 material from this card; Set 1 of your banished "Wiccanthrope" Spells, and it can be activated this turn, then you can banish 1 Spell from your hand, field, or GY, and if you do, return 1 of your banished "Wiccanthrope" Spells to the GY, except the Spell banished by this effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WICCANTHROPE}
function s.xyzcheck(g,tp,xyz)
	return g:IsExists(Card.IsSetCard,1,nil,SET_WICCANTHROPE,xyz,SUMMON_TYPE_XYZ,tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,1)+Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return g:IsExists(Card.IsAbleToRemove,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,PLAYER_ALL,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)+Duel.GetDecktopGroup(1-tp,1)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICCANTHROPE) and c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
function s.rmfilter(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.tgfilter(c,ex)
	return c:IsFaceup() and c:IsSetCard(SET_WICCANTHROPE) and c:IsSpell() and c~=ex
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if not (sc and Duel.SSet(tp,sc)>0) then return end
	if sc:IsQuickPlaySpell() then
		--It can be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	--Then you can banish 1 Spell from your hand, field, or GY, and if you do, return 1 of your banished "Wiccanthrope" Spells to the GY, except the Spell banished by this effect
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if not (rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil,rc)
		if #tg>0 then
			Duel.SendtoGrave(tg,REASON_EFFECT|REASON_RETURN)
		end
	end
end
