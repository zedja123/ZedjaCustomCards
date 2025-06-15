--Wiccanthrope Stormgnarl
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()

	-- ATK/DEF Debuff for opponent's monsters based on face-up banished Spells
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkdefval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	-- Quick Effect: Detach 1; Special Summon 1 banished Wiccanthrope, banish Spell, attach Spell from Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRankBelow(4) and c:IsSetCard(0xf11,lc,SUMMON_TYPE_XYZ,tp)
end

function s.banishspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsFaceup()
end

function s.atkdefval(e,c)
	return Duel.GetMatchingGroupCount(s.banishspellfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*-300
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.spbanishedfilter(c,e,tp)
	return c:IsSetCard(0xf11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.spellbanishfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.deckspellfilter(c)
	return c:IsSpell()
end

function s.xyzfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsControler(tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spbanishedfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spbanishedfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- Shuffle into Deck when leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e1,true)

		-- Optional: banish Spell and attach from Deck
		if Duel.IsExistingMatchingCard(s.spellbanishfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local banish=Duel.SelectMatchingCard(tp,s.spellbanishfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
			if Duel.Remove(banish,POS_FACEUP,REASON_COST)~=0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local tg=Duel.SelectMatchingCard(tp,s.deckspellfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #tg>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
					if xyz then
						Duel.Overlay(xyz,tg)
					end
				end
			end
		end
	end
end
