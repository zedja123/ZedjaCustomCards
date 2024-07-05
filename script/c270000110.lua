--Wiccanthrope Sperelfler
local s,id=GetID()
function c270000110.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	-- ATK/DEF boost for Banished Spells
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- Quick Effect: Detach material, Special Summon from GY, banish Spell, attach Spell from Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRankBelow(4) and c:IsSetCard(0xf11,lc,SUMMON_TYPE_XYZ,tp)
end

-- ATK/DEF boost function
function s.atktg(e,c)
	return c:IsSetCard(0xf11) and c:IsType(TYPE_MONSTER)
end

function s.atkspellbanish(e,c)
	return c:IsType(TYPE_SPELL) and c:IsFaceup()
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,TYPE_SPELL)*300
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,TYPE_SPELL) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_SPELL) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.attachfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsForbidden()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- Banish it when it leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- Optional banish Spell and attach Spell from Deck
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,TYPE_SPELL) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,TYPE_SPELL)
			if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				local tg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
				if #tg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
					local ag=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_DECK,0,1,1,nil)
					if #ag>0 then
						Duel.Overlay(tg:GetFirst(),ag)
					end
				end
			end
		end
	end
end