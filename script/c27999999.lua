--
--Revolution des Fleurs
--scripted by Zedja
local s,id=GetID()
local CARD_NECRO_FLEUR=99000151
local CARD_NECRO_SYNCHRON=48421595
local CARD_SORCIERE_DE_FLEUR=36405256
function s.initial_effect(c)
	--Activates at the start of your first turn
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={CARD_NECRO_FLEUR,CARD_NECRO_SYNCHRON,CARD_SORCIERE_DE_FLEUR}
function s.deckfilter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:GetAttack()==2900
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()<=2 and Duel.IsTurnPlayer(tp)
		and Duel.GetMatchingGroupCount(s.deckfilter,tp,LOCATION_DECK,0,nil)>=6
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--1: During this Duel, you can Normal Summon/Set DARK Spellcaster monsters with 2900 ATK without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.ntcon)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,6))
	e2:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e2,tp)
	--If this Skill was activated on the 2nd turn, also play 1 "Necro Fleur" from outside of your Deck in face-down Defense Position
	if Duel.GetTurnCount()==2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local fleur=Duel.CreateToken(tp,CARD_NECRO_FLEUR)
		Duel.MoveToField(fleur,tp,tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true)
		Duel.RaiseEvent(fleur,EVENT_MSET,e,REASON_EFFECT,tp,tp,0)
	end
	--2 and 3: once per Duel each
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	Duel.RegisterEffect(e3,tp)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:GetAttack()==2900 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
function s.canuse2(tp)
	return Duel.GetFlagEffect(tp,id+1)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_NECRO_SYNCHRON)
end
function s.canuse3(tp)
	return Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_SORCIERE_DE_FLEUR)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and (s.canuse2(tp) or s.canuse3(tp))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local op=Duel.SelectEffect(tp,{s.canuse2(tp),aux.Stringid(id,1)},{s.canuse3(tp),aux.Stringid(id,2)})
	if op==1 then
		s.effect2(e,tp)
	elseif op==2 then
		s.effect3(e,tp)
	end
end
function s.effect2(e,tp)
	Duel.RegisterFlagEffect(tp,id+1,0,0,1)
	--2: Shuffle 1 card from your hand into the Deck, then play 1 "Necro Synchron" from your Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local tc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_NECRO_SYNCHRON)
	if not tc or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.BreakEffect()
	if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	--Then, you can decrease the Level of 1 monster on your field by 1 or 2
	local lg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,2),tp,LOCATION_MZONE,0,nil)
	if #lg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sc=lg:Select(tp,1,1,nil):GetFirst()
	local ct=1
	if sc:IsLevelAbove(3) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		ct=Duel.AnnounceNumber(tp,1,2)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-ct)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	sc:RegisterEffect(e1)
end
function s.effect3(e,tp)
	Duel.RegisterFlagEffect(tp,id+2,0,0,1)
	--3: Send 1 monster from your field to the Graveyard, then play 1 "Sorciere de Fleur" from your Deck in face-down Defense Position
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	local tc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_SORCIERE_DE_FLEUR)
	if not tc or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.BreakEffect()
	Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true)
	Duel.RaiseEvent(tc,EVENT_MSET,e,REASON_EFFECT,tp,tp,0)
end
